import 'package:intl/intl.dart';

class Helper {
  static String formatPrice(double price) {
    return NumberFormat('#,##0.00').format(price);
  }
}
