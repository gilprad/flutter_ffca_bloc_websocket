import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/crypto_price_point.dart';
import '../../domain/repositories/crypto_price_repository.dart';
import 'market_info_event.dart';
import 'market_info_state.dart';

class MarketInfoBloc extends Bloc<MarketInfoEvent, MarketInfoState> {
  MarketInfoBloc({
    required CryptoPriceRepository repository,
    this.maxPointsPerSymbol = 1200,
  }) : _repository = repository,
       super(MarketInfoState.initial()) {
    on<MarketInfoStarted>(_onStarted);
    on<MarketInfoSymbolSelected>(_onSymbolSelected);
    on<MarketInfoPointReceived>(_onPointReceived);
    on<MarketInfoStreamErrored>(_onStreamErrored);
  }

  final CryptoPriceRepository _repository;
  final int maxPointsPerSymbol;

  StreamSubscription<CryptoPricePoint>? _sub;
  String? _subscribedSymbol;

  Future<void> _onStarted(
    MarketInfoStarted event,
    Emitter<MarketInfoState> emit,
  ) async {
    await _cancelSubscription();

    final symbols = event.symbols;
    final selected = symbols.isEmpty ? null : symbols.first;
    emit(
      state.copyWith(
        status: MarketInfoStatus.connecting,
        symbols: symbols,
        selectedSymbol: selected,
        pointsBySymbol: {for (final s in symbols) s: <CryptoPricePoint>[]},
        errorMessage: null,
      ),
    );

    await _subscribeToSelectedSymbol(selected, emit);
  }

  void _onPointReceived(
    MarketInfoPointReceived event,
    Emitter<MarketInfoState> emit,
  ) {
    final point = event.point;
    final current = state.pointsBySymbol[point.symbol] ?? const [];
    final next = [...current, point];
    final trimmed = next.length <= maxPointsPerSymbol
        ? next
        : next.sublist(next.length - maxPointsPerSymbol);

    final updatedMap = {...state.pointsBySymbol, point.symbol: trimmed};

    final selected = state.selectedSymbol;
    final shouldAutoSelect =
        selected == null || (updatedMap[selected]?.isEmpty ?? true);

    emit(
      state.copyWith(
        pointsBySymbol: updatedMap,
        selectedSymbol: shouldAutoSelect ? point.symbol : selected,
      ),
    );
  }

  void _onStreamErrored(
    MarketInfoStreamErrored event,
    Emitter<MarketInfoState> emit,
  ) {
    emit(
      state.copyWith(
        status: MarketInfoStatus.error,
        errorMessage: event.message,
      ),
    );
  }

  Future<void> _onSymbolSelected(
    MarketInfoSymbolSelected event,
    Emitter<MarketInfoState> emit,
  ) async {
    final next = event.symbol;
    if (next == state.selectedSymbol && next == _subscribedSymbol) return;

    emit(
      state.copyWith(
        status: MarketInfoStatus.connecting,
        selectedSymbol: next,
        pointsBySymbol: {
          for (final s in state.symbols) s: <CryptoPricePoint>[],
        },
        errorMessage: null,
      ),
    );

    await _subscribeToSelectedSymbol(next, emit);
  }

  Future<void> _subscribeToSelectedSymbol(
    String? symbol,
    Emitter<MarketInfoState> emit,
  ) async {
    await _cancelSubscription();
    if (symbol == null || symbol.isEmpty) return;

    try {
      _subscribedSymbol = symbol;
      final stream = _repository.subscribe(symbols: [symbol]);
      emit(
        state.copyWith(status: MarketInfoStatus.streaming, errorMessage: null),
      );

      _sub = stream.listen(
        (point) => add(MarketInfoPointReceived(point)),
        onError: (Object e, StackTrace st) {
          add(MarketInfoStreamErrored(e.toString()));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MarketInfoStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _cancelSubscription() async {
    _subscribedSymbol = null;
    await _sub?.cancel();
    _sub = null;
  }

  @override
  Future<void> close() async {
    await _cancelSubscription();
    return super.close();
  }
}
