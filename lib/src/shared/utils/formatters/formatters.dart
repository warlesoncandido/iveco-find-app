class Formatters {
  /// Formata um CNPJ no padrão 00.000.000/0000-00.
  ///
  /// Aceita o valor com ou sem máscara e também o CNPJ alfanumérico.
  /// Se o valor não tiver 14 caracteres, retorna o valor original.
  static String cnpj(String value) {
    final cnpj = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();

    if (cnpj.length != 14) return value;

    return '${cnpj.substring(0, 2)}.'
        '${cnpj.substring(2, 5)}.'
        '${cnpj.substring(5, 8)}/'
        '${cnpj.substring(8, 12)}-'
        '${cnpj.substring(12, 14)}';
  }
}
