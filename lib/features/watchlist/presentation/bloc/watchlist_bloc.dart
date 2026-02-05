import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../market_info/domain/entities/crypto_price_point.dart';
import '../../../market_info/domain/repositories/crypto_price_repository.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  WatchlistBloc({required CryptoPriceRepository repository})
    : _repository = repository,
      super(WatchlistState.initial()) {
    on<WatchlistStarted>(_onStarted);
    on<WatchlistPointReceived>(_onPointReceived);
    on<WatchlistStreamErrored>(_onStreamErrored);
  }

  final CryptoPriceRepository _repository;
  StreamSubscription<CryptoPricePoint>? _sub;

  Future<void> _onStarted(
    WatchlistStarted event,
    Emitter<WatchlistState> emit,
  ) async {
    await _sub?.cancel();

    emit(
      state.copyWith(
        status: WatchlistStatus.connecting,
        symbols: event.symbols,
        latestBySymbol: const {},
        errorMessage: null,
      ),
    );

    try {
      final stream = _repository.subscribe(symbols: event.symbols);
      emit(state.copyWith(status: WatchlistStatus.streaming));

      _sub = stream.listen(
        (point) => add(WatchlistPointReceived(point)),
        onError: (Object e, StackTrace st) =>
            add(WatchlistStreamErrored(e.toString())),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WatchlistStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onPointReceived(
    WatchlistPointReceived event,
    Emitter<WatchlistState> emit,
  ) {
    emit(
      state.copyWith(
        latestBySymbol: {
          ...state.latestBySymbol,
          event.point.symbol: event.point,
        },
      ),
    );
  }

  void _onStreamErrored(
    WatchlistStreamErrored event,
    Emitter<WatchlistState> emit,
  ) {
    emit(
      state.copyWith(
        status: WatchlistStatus.error,
        errorMessage: event.message,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
