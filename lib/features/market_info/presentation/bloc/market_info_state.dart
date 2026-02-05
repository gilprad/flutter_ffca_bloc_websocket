import 'package:equatable/equatable.dart';

import '../../domain/entities/crypto_price_point.dart';

enum MarketInfoStatus { initial, connecting, streaming, error }

class MarketInfoState extends Equatable {
  const MarketInfoState({
    required this.status,
    required this.symbols,
    required this.selectedSymbol,
    required this.pointsBySymbol,
    this.errorMessage,
  });

  factory MarketInfoState.initial() => const MarketInfoState(
    status: MarketInfoStatus.initial,
    symbols: [],
    selectedSymbol: null,
    pointsBySymbol: {},
  );

  final MarketInfoStatus status;
  final List<String> symbols;
  final String? selectedSymbol;
  final Map<String, List<CryptoPricePoint>> pointsBySymbol;
  final String? errorMessage;

  List<CryptoPricePoint> pointsForSelected() => selectedSymbol == null
      ? const []
      : (pointsBySymbol[selectedSymbol] ?? []);

  CryptoPricePoint? lastForSelected() {
    final pts = pointsForSelected();
    return pts.isEmpty ? null : pts.last;
  }

  MarketInfoState copyWith({
    MarketInfoStatus? status,
    List<String>? symbols,
    String? selectedSymbol,
    Map<String, List<CryptoPricePoint>>? pointsBySymbol,
    String? errorMessage,
  }) {
    return MarketInfoState(
      status: status ?? this.status,
      symbols: symbols ?? this.symbols,
      selectedSymbol: selectedSymbol ?? this.selectedSymbol,
      pointsBySymbol: pointsBySymbol ?? this.pointsBySymbol,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    symbols,
    selectedSymbol,
    pointsBySymbol,
    errorMessage,
  ];
}
