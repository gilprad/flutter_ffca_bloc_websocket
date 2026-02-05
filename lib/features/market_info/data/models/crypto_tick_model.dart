class CryptoTickModel {
  const CryptoTickModel({
    required this.symbol,
    required this.price,
    required this.timestampMs,
    this.quantity,
    this.dailyChangePercent,
    this.dailyDiff,
  });

  factory CryptoTickModel.fromJson(Map<String, dynamic> json) {
    final symbol = (json['s'] ?? '').toString();

    double? asDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    final price = asDouble(json['p']);
    final ts = json['t'];
    final timestampMs = ts is int ? ts : int.tryParse(ts.toString());

    if (symbol.isEmpty || price == null || timestampMs == null) {
      throw const FormatException('Invalid data payload');
    }

    return CryptoTickModel(
      symbol: symbol,
      price: price,
      quantity: asDouble(json['q']),
      dailyChangePercent: asDouble(json['dc']),
      dailyDiff: asDouble(json['dd']),
      timestampMs: timestampMs,
    );
  }

  final String symbol;
  final double price;
  final double? quantity;
  final double? dailyChangePercent;
  final double? dailyDiff;
  final int timestampMs;
}
