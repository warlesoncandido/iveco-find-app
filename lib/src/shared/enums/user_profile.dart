enum UserProfile {
  administrador('ADMINISTRADOR', 'Administrador'),
  gestor('GESTOR', 'Gestor'),
  operacional('OPERACIONAL', 'Operacional'),
  consulta('CONSULTA', 'Consulta');

  final String value;
  final String label;

  const UserProfile(this.value, this.label);

  static UserProfile? fromValue(String? value) {
    for (final item in UserProfile.values) {
      if (item.value == value) return item;
    }
    return null;
  }
}
