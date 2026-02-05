import 'package:equatable/equatable.dart';

class CryptoPricePoint extends Equatable {
  const CryptoPricePoint({
    required this.symbol,
    required this.timeSec,
    required this.price,
    this.quantity,
    this.dailyChangePercent,
    this.dailyDiff,
  });

  final String symbol;

  final DateTime timeSec;

  final double price;

  final double? quantity;

  final double? dailyChangePercent;

  final double? dailyDiff;

  @override
  List<Object?> get props => [
    symbol,
    timeSec,
    price,
    quantity,
    dailyChangePercent,
    dailyDiff,
  ];
}
