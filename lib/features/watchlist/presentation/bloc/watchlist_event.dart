import 'package:equatable/equatable.dart';

import '../../../market_info/domain/entities/crypto_price_point.dart';

sealed class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => const [];
}

final class WatchlistStarted extends WatchlistEvent {
  const WatchlistStarted({required this.symbols});

  final List<String> symbols;

  @override
  List<Object?> get props => [symbols];
}

final class WatchlistPointReceived extends WatchlistEvent {
  const WatchlistPointReceived(this.point);

  final CryptoPricePoint point;

  @override
  List<Object?> get props => [point];
}

final class WatchlistStreamErrored extends WatchlistEvent {
  const WatchlistStreamErrored(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
