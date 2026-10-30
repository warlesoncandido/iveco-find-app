import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final isDeleting = newValue.text.length < oldValue.text.length;

    String numbers = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final oldNumbers = oldValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Se o usuário apagou um caractere de formatação (não um dígito),
    // remove também o último dígito para o backspace funcionar de forma intuitiva.
    if (isDeleting &&
        numbers.length == oldNumbers.length &&
        numbers.isNotEmpty) {
      numbers = numbers.substring(0, numbers.length - 1);
    }

    if (numbers.length > 11) {
      numbers = numbers.substring(0, 11);
    }

    final formatted = _format(numbers);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _format(String numbers) {
    if (numbers.isEmpty) return '';

    String formatted = '(';

    if (numbers.length >= 2) {
      formatted += '${numbers.substring(0, 2)}) ';
    } else {
      return formatted + numbers;
    }

    if (numbers.length > 2) {
      if (numbers.length >= 7) {
        if (numbers.length == 11) {
          formatted += '${numbers.substring(2, 7)}-';
          formatted += numbers.substring(7, 11);
        } else {
          formatted += '${numbers.substring(2, 6)}-';
          formatted += numbers.substring(6);
        }
      } else {
        formatted += numbers.substring(2);
      }
    }

    return formatted;
  }
}
