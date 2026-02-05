import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/market_info/data/datasources/crypto_ws_data_source.dart';
import '../../features/market_info/data/models/crypto_tick_model.dart';
import '../../features/market_info/domain/entities/crypto_price_point.dart';

class WsManager {
  WsManager({required CryptoWsDataSource dataSource})
    : _dataSource = dataSource;

  final CryptoWsDataSource _dataSource;

  final Map<String, int> _refCounts = <String, int>{};
  final Set<String> _activeSymbols = <String>{};

  final _pointsController = StreamController<CryptoPricePoint>.broadcast();
  Stream<CryptoPricePoint> get points => _pointsController.stream;

  StreamSubscription<CryptoTickModel>? _sub;

  final Map<String, int> _currentSec = {};
  final Map<String, CryptoTickModel> _buffer = {};

  bool _paused = false;
  bool _started = false;

  Future<void> addSymbols(List<String> symbols) async {
    final newlyAdded = <String>[];
    for (final s in symbols) {
      final next = (_refCounts[s] ?? 0) + 1;
      _refCounts[s] = next;
      if (next == 1) newlyAdded.add(s);
    }

    if (newlyAdded.isEmpty) return;
    _activeSymbols.addAll(newlyAdded);

    debugPrint(
      '[WSM] addSymbols +${newlyAdded.join(",")} active=${_activeSymbols.length}',
    );

    if (_paused) return;

    await _ensureStarted();
    await _dataSource.subscribe(symbols: newlyAdded);
  }

  Future<void> removeSymbols(List<String> symbols) async {
    final symbolToRemove = <String>[];

    for (final s in symbols) {
      final cur = _refCounts[s] ?? 0;
      if (cur <= 1) {
        _refCounts.remove(s);
        if (_activeSymbols.remove(s)) {
          symbolToRemove.add(s);
        }
      } else {
        _refCounts[s] = cur - 1;
      }
    }

    if (symbolToRemove.isEmpty) return;

    debugPrint(
      '[WSM] removeSymbols -${symbolToRemove.join(",")} active=${_activeSymbols.length}',
    );

    for (final s in symbolToRemove) {
      _flushSymbol(s);
    }

    if (!_paused) {
      await _dataSource.unsubscribe(symbols: symbolToRemove);
    }

    if (_activeSymbols.isEmpty) {
      await _stopAndCloseSocket();
    }
  }

  Future<void> pause() async {
    if (_paused) return;
    _paused = true;

    debugPrint('[WSM] pause active=${_activeSymbols.length}');

    try {
      if (_activeSymbols.isNotEmpty) {
        await _dataSource.unsubscribe(symbols: _activeSymbols.toList());
      }
    } catch (e) {
      debugPrint('[WSM] pause unsubscribe error: $e');
    }

    await _stopAndCloseSocket();
  }

  Future<void> resume() async {
    if (!_paused) return;
    _paused = false;

    debugPrint('[WSM] resume active=${_activeSymbols.length}');

    if (_activeSymbols.isEmpty) return;
    await _ensureStarted();
    await _dataSource.subscribe(symbols: _activeSymbols.toList());
  }

  Future<void> closeAll() async {
    debugPrint('[WSM] closeAll active=${_activeSymbols.length}');
    for (final s in _activeSymbols.toList()) {
      _flushSymbol(s);
    }
    _activeSymbols.clear();
    _refCounts.clear();
    await _stopAndCloseSocket();
  }

  Future<void> _ensureStarted() async {
    if (_started) return;
    _started = true;

    await _dataSource.connect();

    _sub ??= _dataSource.data.listen(
      _onTick,
      onError: (e, st) => _pointsController.addError(e, st),
    );
  }

  Future<void> _stopAndCloseSocket() async {
    await _sub?.cancel();
    _sub = null;
    _started = false;

    try {
      await _dataSource.close();
    } catch (e) {
      debugPrint('[WSM] close socket error: $e');
    }
  }

  void _onTick(CryptoTickModel data) {
    if (_pointsController.isClosed) return;

    final symbol = data.symbol;
    if (!_activeSymbols.contains(symbol)) {
      return;
    }

    final sec = data.timestampMs ~/ 1000;
    final cur = _currentSec[symbol];
    if (cur == null) {
      _currentSec[symbol] = sec;
      _buffer[symbol] = data;
      return;
    }

    if (sec == cur) {
      _buffer[symbol] = data;
      return;
    }

    if (sec < cur) return;

    final prev = _buffer[symbol];
    if (prev != null) {
      _pointsController.add(_toPoint(prev, secOverride: cur));
    }

    _currentSec[symbol] = sec;
    _buffer[symbol] = data;
  }

  void _flushSymbol(String symbol) {
    final sec = _currentSec[symbol];
    final data = _buffer[symbol];
    if (sec != null && data != null) {
      _pointsController.add(_toPoint(data, secOverride: sec));
    }
    _currentSec.remove(symbol);
    _buffer.remove(symbol);
  }

  CryptoPricePoint _toPoint(CryptoTickModel data, {required int secOverride}) {
    return CryptoPricePoint(
      symbol: data.symbol,
      timeSec: DateTime.fromMillisecondsSinceEpoch(secOverride * 1000),
      price: data.price,
      quantity: data.quantity,
      dailyChangePercent: data.dailyChangePercent,
      dailyDiff: data.dailyDiff,
    );
  }
}
