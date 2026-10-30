import 'package:flutter/services.dart';

class MoneyInputFormatter extends TextInputFormatter {
  MoneyInputFormatter({this.symbol = 'R\$ '});

  final String symbol;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final value = int.parse(digits);

    final cents = value % 100;
    final integer = value ~/ 100;

    final integerFormatted = _formatThousands(integer);

    final text = '$symbol$integerFormatted,${cents.toString().padLeft(2, '0')}';

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  String _formatThousands(int value) {
    final str = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      final position = str.length - i;

      buffer.write(str[i]);

      if (position > 1 && position % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }
}
