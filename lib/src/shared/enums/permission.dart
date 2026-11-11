import 'package:iveco_find/src/shared/enums/user_profile.dart';

/// Espelho da matriz Perfil × permissão da API (`src/shared/permissoes.ts`).
/// A API é quem decide; aqui só serve para esconder o que daria 403.
enum Permission {
  contaPropria('conta:propria'),
  ativosLer('ativos:ler'),
  ativosEscrever('ativos:escrever'),
  ativosMovimentar('ativos:movimentar'),
  ativosBaixar('ativos:baixar'),
  ativosExcluir('ativos:excluir'),
  cadastrosLer('cadastros:ler'),
  cadastrosGerir('cadastros:gerir'),
  usuariosGerir('usuarios:gerir');

  final String value;
  const Permission(this.value);

  static const _base = {
    Permission.contaPropria,
    Permission.ativosLer,
    Permission.cadastrosLer,
  };
  static const _operacao = {
    ..._base,
    Permission.ativosEscrever,
    Permission.ativosMovimentar,
  };

  static Set<Permission> forProfile(String? perfil) {
    return switch (UserProfile.fromValue(perfil)) {
      UserProfile.administrador => Permission.values.toSet(),
      UserProfile.gestor => {..._operacao, Permission.ativosBaixar},
      UserProfile.operacional => _operacao,
      UserProfile.consulta => _base,
      null => const {},
    };
  }
}
