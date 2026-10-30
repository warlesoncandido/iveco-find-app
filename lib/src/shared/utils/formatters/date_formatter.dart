import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Mantém somente os números
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Limita a 8 dígitos: ddMMyyyy
    final limitedDigits = digits.length > 8 ? digits.substring(0, 8) : digits;

    final buffer = StringBuffer();

    for (var i = 0; i < limitedDigits.length; i++) {
      buffer.write(limitedDigits[i]);

      if (i == 1 || i == 3) {
        if (i != limitedDigits.length - 1) {
          buffer.write('/');
        }
      }
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
