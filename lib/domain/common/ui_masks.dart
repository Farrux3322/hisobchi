import 'package:easy_localization/easy_localization.dart';

class UIMasks {
  static String mPrice(num price, {int decimalDigits = 0}) {
    final formatCurrency = NumberFormat.currency(
      symbol: '',
      decimalDigits: decimalDigits,
    );
    return formatCurrency.format(price);
  }
}
