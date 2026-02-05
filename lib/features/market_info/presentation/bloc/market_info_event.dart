import 'package:equatable/equatable.dart';

import '../../domain/entities/crypto_price_point.dart';

sealed class MarketInfoEvent extends Equatable {
  const MarketInfoEvent();

  @override
  List<Object?> get props => const [];
}

final class MarketInfoStarted extends MarketInfoEvent {
  const MarketInfoStarted({required this.symbols});

  final List<String> symbols;

  @override
  List<Object?> get props => [symbols];
}

final class MarketInfoSymbolSelected extends MarketInfoEvent {
  const MarketInfoSymbolSelected(this.symbol);

  final String symbol;

  @override
  List<Object?> get props => [symbol];
}

final class MarketInfoPointReceived extends MarketInfoEvent {
  const MarketInfoPointReceived(this.point);

  final CryptoPricePoint point;

  @override
  List<Object?> get props => [point];
}

final class MarketInfoStreamErrored extends MarketInfoEvent {
  const MarketInfoStreamErrored(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
