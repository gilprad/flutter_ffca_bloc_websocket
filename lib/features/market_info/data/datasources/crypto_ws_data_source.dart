import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/crypto_tick_model.dart';

class CryptoWsDataSource {
  static const String wsUrl =
      'wss://ws.eodhistoricaldata.com/ws/crypto?api_token=demo';

  static const bool _logAllIncomingFrames = kDebugMode;
  static const bool _logRatePerSecond = kDebugMode;
  static const bool _logDecodeErrors = kDebugMode;

  WebSocket? _socket;
  StreamSubscription<dynamic>? _socketSub;
  bool _unsubscribed = false;
  bool _closing = false;

  final _controller = StreamController<CryptoTickModel>.broadcast();

  Stream<CryptoTickModel> get data => _controller.stream;
  bool get isConnected => _socket?.readyState == WebSocket.open;
  bool get isUnsubscribed => _unsubscribed;

  int? _rateWindowSec;
  int _rateWindowCount = 0;

  Future<void> connect() async {
    if (_socket != null) return;
    if (_closing) return;

    final socket = await WebSocket.connect(wsUrl);
    socket.pingInterval = const Duration(seconds: 10);
    _socket = socket;
    _unsubscribed = false;
    _rateWindowSec = null;
    _rateWindowCount = 0;
    debugPrint('[WS] connected');

    _socketSub = socket.listen(
      (dynamic message) {
        if (_logAllIncomingFrames) {
          _logIncomingFrame(message);
        }
        _handleMessage(message);
      },
      onError: (Object err, StackTrace st) {
        if (!_controller.isClosed) {
          _controller.addError(err, st);
        }
      },
      onDone: () {
        debugPrint('[WS] connection closed');
      },
      cancelOnError: false,
    );
  }

  Future<void> subscribe({required List<String> symbols}) async {
    if (symbols.isEmpty) return;
    await connect();
    final socket = _socket;
    if (socket == null) return;

    final req = jsonEncode({
      'action': 'subscribe',
      'symbols': symbols.join(','),
    });
    socket.add(req);
    _unsubscribed = false;
    debugPrint('[WS] subscribe symbols=${symbols.join(",")}');
  }

  Future<void> unsubscribe({required List<String> symbols}) async {
    if (symbols.isEmpty) return;
    final socket = _socket;
    if (socket == null) return;

    try {
      final req = jsonEncode({
        'action': 'unsubscribe',
        'symbols': symbols.join(','),
      });
      socket.add(req);
      debugPrint('[WS] unsubscribe symbols=${symbols.join(",")}');
      _unsubscribed = true;
    } catch (e) {
      debugPrint('[WS] unsubscribe send failed: $e');
    }
  }

  Future<void> close() async {
    final socket = _socket;
    _socket = null;
    _closing = true;

    try {
      await _socketSub?.cancel();
      _socketSub = null;
      if (socket != null) {
        try {
          await socket.close();
          debugPrint('[WS] socket closed');
        } catch (e) {
          debugPrint('[WS] socket close failed: $e');
        }
      }
    } finally {
      _closing = false;
    }
  }

  Future<void> connectAndSubscribe({required List<String> symbols}) async {
    await subscribe(symbols: symbols);
  }

  void _handleMessage(dynamic message) {
    if (_controller.isClosed) return;

    final text = message.toString().trim();
    if (text.isEmpty) return;

    final ticks = <CryptoTickModel>[];

    final decodedWholeFrame = _tryDecodeAndCollect(text, ticks);
    if (!decodedWholeFrame || ticks.isEmpty) {
      for (final line in text.split('\n')) {
        final l = line.trim();
        if (l.isEmpty) continue;
        _tryDecodeAndCollect(l, ticks);
      }
    }

    if (ticks.isEmpty) return;

    if (_logRatePerSecond) {
      _bumpRatePerSecond(ticks.length);
    }

    for (final t in ticks) {
      if (_controller.isClosed) return;
      _controller.add(t);
    }
  }

  bool _tryDecodeAndCollect(String jsonText, List<CryptoTickModel> out) {
    try {
      final decoded = jsonDecode(jsonText);
      _collectTicksFromDecoded(decoded, out);
      return true;
    } catch (e, st) {
      if (_logDecodeErrors) {
        debugPrint('[WS] json decode failed: $e');
        debugPrint('$st');
      }
      return false;
    }
  }

  void _collectTicksFromDecoded(dynamic decoded, List<CryptoTickModel> out) {
    if (decoded is Map<String, dynamic>) {
      _handleDecodedMap(decoded, out);
      return;
    }

    if (decoded is List) {
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          _handleDecodedMap(item, out);
        }
      }
    }
  }

  void _handleDecodedMap(Map<String, dynamic> m, List<CryptoTickModel> out) {
    if (_controller.isClosed) return;

    final status = m['status']?.toString();
    final error = m['error']?.toString();
    if (status == 'error' || error != null) {
      _controller.addError(
        Exception(
          [
            'WS message',
            if (status != null) 'status=$status',
            if (error != null) 'error=$error',
          ].join(' | '),
        ),
      );
    }

    if (!_looksLikeTick(m)) return;

    try {
      out.add(CryptoTickModel.fromJson(m));
    } catch (e, st) {
      if (_logDecodeErrors) {
        debugPrint('[WS] tick parse failed: $e');
        debugPrint('$st');
      }
    }
  }

  bool _looksLikeTick(Map<String, dynamic> m) {
    return m.containsKey('s') && m.containsKey('p') && m.containsKey('t');
  }

  void _bumpRatePerSecond(int count) {
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final window = _rateWindowSec;
    if (window == null) {
      _rateWindowSec = nowSec;
      _rateWindowCount = count;
      return;
    }

    if (nowSec == window) {
      _rateWindowCount += count;
      return;
    }

    debugPrint('[WS] rate: dalam 1 detik masuk $_rateWindowCount data');
    _rateWindowSec = nowSec;
    _rateWindowCount = count;
  }

  void _logIncomingFrame(dynamic message) {
    String raw;
    if (message is String) {
      raw = message;
    } else if (message is List<int>) {
      try {
        raw = utf8.decode(message);
      } catch (_) {
        raw = 'base64:${base64Encode(message)}';
      }
    } else {
      raw = message.toString();
    }

    final ts = DateTime.now().toIso8601String();
    _debugPrintChunked('[WS] <= ($ts) ${raw.length} chars\n$raw');
  }

  void _debugPrintChunked(String message, {int chunkSize = 900}) {
    if (message.length <= chunkSize) {
      debugPrint(message);
      return;
    }

    final totalChunks = (message.length / chunkSize).ceil();
    for (var i = 0; i < message.length; i += chunkSize) {
      final end = (i + chunkSize < message.length)
          ? i + chunkSize
          : message.length;
      final chunkIndex = (i ~/ chunkSize) + 1;
      debugPrint(
        '[WS] chunk $chunkIndex/$totalChunks ${message.substring(i, end)}',
      );
    }
  }

  Future<void> unsubscribeAndClose({required List<String> symbols}) async {
    await unsubscribe(symbols: symbols);
    await close();
  }

  Future<void> dispose() async {
    await close();
    await _controller.close();
  }
}
