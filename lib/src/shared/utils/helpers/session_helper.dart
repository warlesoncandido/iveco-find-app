import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:iveco_find/src/core/services/i_local_storage.dart';
import 'package:iveco_find/src/shared/enums/local_storage_keys.dart';
import 'package:iveco_find/src/shared/enums/permission.dart';
import 'package:iveco_find/src/shared/models/auth_model.dart';

/// Dados da sessão salvos no login (`auth` no storage).
class SessionHelper {
  static Future<String?> perfil() async {
    final auth = await GetIt.instance.get<LocalStorage>().getString(
      LocalStorageKeys.auth.name(),
    );
    if (auth == null || auth.isEmpty) return null;
    return AuthModel.fromJson(json.decode(auth)).user.perfil;
  }

  static Future<bool> can(Permission permission) async =>
      Permission.forProfile(await perfil()).contains(permission);

  /// Sufixo de query para listas de cadastros: `incluirInativos=true` exige
  /// `cadastros:gerir`; sem ela, a API responde 403 SEM_PERMISSAO.
  static Future<String> includeInactiveQuery() async =>
      await can(Permission.cadastrosGerir) ? '&incluirInativos=true' : '';
}
