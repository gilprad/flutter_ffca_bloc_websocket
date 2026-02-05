import 'package:equatable/equatable.dart';

import '../../../market_info/domain/entities/crypto_price_point.dart';

enum WatchlistStatus { initial, connecting, streaming, error }

class WatchlistState extends Equatable {
  const WatchlistState({
    required this.status,
    required this.symbols,
    required this.latestBySymbol,
    this.errorMessage,
  });

  factory WatchlistState.initial() => const WatchlistState(
    status: WatchlistStatus.initial,
    symbols: [],
    latestBySymbol: {},
  );

  final WatchlistStatus status;
  final List<String> symbols;
  final Map<String, CryptoPricePoint> latestBySymbol;
  final String? errorMessage;

  CryptoPricePoint? latestFor(String symbol) => latestBySymbol[symbol];

  WatchlistState copyWith({
    WatchlistStatus? status,
    List<String>? symbols,
    Map<String, CryptoPricePoint>? latestBySymbol,
    String? errorMessage,
  }) {
    return WatchlistState(
      status: status ?? this.status,
      symbols: symbols ?? this.symbols,
      latestBySymbol: latestBySymbol ?? this.latestBySymbol,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, symbols, latestBySymbol, errorMessage];
}
