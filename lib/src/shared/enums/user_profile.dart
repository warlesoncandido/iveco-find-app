import 'package:iveco_find/l10n/app_localizations.dart';

enum UserProfile {
  administrador('ADMINISTRADOR'),
  gestor('GESTOR'),
  operacional('OPERACIONAL'),
  consulta('CONSULTA');

  final String value;

  const UserProfile(this.value);

  String label(AppLocalizations l) => switch (this) {
    UserProfile.administrador => l.profileAdministrator,
    UserProfile.gestor => l.profileManager,
    UserProfile.operacional => l.profileOperational,
    UserProfile.consulta => l.profileViewer,
  };

  static UserProfile? fromValue(String? value) {
    for (final item in UserProfile.values) {
      if (item.value == value) return item;
    }
    return null;
  }
}
