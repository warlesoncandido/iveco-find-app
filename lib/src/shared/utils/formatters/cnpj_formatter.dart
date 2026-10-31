import 'package:flutter/services.dart';

class CnpjInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final isDeleting = newValue.text.length < oldValue.text.length;

    // Mantém letras e números para suportar o CNPJ alfanumérico
    String chars = _clean(newValue.text);
    final oldChars = _clean(oldValue.text);

    // Se o usuário apagou um caractere de formatação (não um dígito),
    // remove também o último caractere para o backspace funcionar de forma intuitiva.
    if (isDeleting && chars.length == oldChars.length && chars.isNotEmpty) {
      chars = chars.substring(0, chars.length - 1);
    }

    // Limita a 14 caracteres: 00.000.000/0000-00
    if (chars.length > 14) {
      chars = chars.substring(0, 14);
    }

    final formatted = _format(chars);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _clean(String value) {
    return value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
  }

  String _format(String chars) {
    final buffer = StringBuffer();

    for (var i = 0; i < chars.length; i++) {
      if (i == 2 || i == 5) buffer.write('.');
      if (i == 8) buffer.write('/');
      if (i == 12) buffer.write('-');

      buffer.write(chars[i]);
    }

    return buffer.toString();
  }
}
