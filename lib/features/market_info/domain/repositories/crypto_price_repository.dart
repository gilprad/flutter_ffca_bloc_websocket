import '../entities/crypto_price_point.dart';

abstract class CryptoPriceRepository {
  Stream<CryptoPricePoint> subscribe({required List<String> symbols});

  Future<void> close();
}
