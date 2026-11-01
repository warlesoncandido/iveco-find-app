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

  /// Texto do `MoneyInputFormatter` ("R$ 1.234,50") → decimal da API ("1234.50").
  static String? toApi(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    final cents = int.parse(digits);
    return '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';
  }
}
