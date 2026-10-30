import 'package:intl/intl.dart';

class MoneyHelper {
  static String formatApiMoney(String value) {
    final number = double.parse(value.replaceAll('\$', '').replaceAll(',', ''));

    return formatMoney(number);
  }

  static String formatMoney(double value) {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    ).format(value);
  }
}
