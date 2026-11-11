import 'package:iveco_find/src/shared/models/user_model.dart';

class UserParams {
  String nome;
  String email;
  String perfil;
  bool ativo;

  UserParams({
    required this.nome,
    required this.email,
    required this.perfil,
    this.ativo = true,
  });

  Map<String, dynamic> toCreateJson() {
    return {'nome': nome.trim(), 'email': email.trim(), 'perfil': perfil};
  }

  /// Só os campos alterados (PATCH). E-mail não é editável.
  Map<String, dynamic> toUpdateJson(UserModel original) {
    final data = <String, dynamic>{};
    if (nome.trim() != original.nome) data['nome'] = nome.trim();
    if (perfil != original.perfil) data['perfil'] = perfil;
    if (ativo != original.ativo) data['ativo'] = ativo;
    return data;
  }
}
