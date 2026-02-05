import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/ws/ws_manager.dart';
import '../../domain/entities/crypto_price_point.dart';
import '../../domain/repositories/crypto_price_repository.dart';

class WsManagedCryptoPriceRepository implements CryptoPriceRepository {
  WsManagedCryptoPriceRepository({required WsManager manager})
    : _manager = manager;

  final WsManager _manager;

  @override
  Stream<CryptoPricePoint> subscribe({required List<String> symbols}) {
    final symbolSet = symbols.toSet();
    StreamSubscription<CryptoPricePoint>? streamSubscription;

    late final StreamController<CryptoPricePoint> streamController;
    streamController = StreamController<CryptoPricePoint>.broadcast(
      onListen: () async {
        debugPrint('[REPO] subscribe symbols=${symbols.join(",")}');
        await _manager.addSymbols(symbols);
        streamSubscription = _manager.points
            .where((p) => symbolSet.contains(p.symbol))
            .listen(streamController.add, onError: streamController.addError);
      },
      onCancel: () async {
        debugPrint('[REPO] unsubscribe symbols=${symbols.join(",")}');
        await streamSubscription?.cancel();
        await _manager.removeSymbols(symbols);
        await streamController.close();
      },
    );

    return streamController.stream;
  }

  @override
  Future<void> close() async {}
}
