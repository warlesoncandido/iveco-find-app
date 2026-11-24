import 'package:iveco_find/src/shared/models/user_model.dart';

class AuthModel {
  final String token;

  /// Ausente em sessões salvas antes do refresh token: sem ele, um 401 leva ao login.
  final String? refreshToken;
  final bool needChangePassword;
  final UserModel user;

  AuthModel({
    required this.token,
    this.refreshToken,
    required this.needChangePassword,
    required this.user,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'],
      refreshToken: json['refreshToken'],
      needChangePassword: json['trocaSenhaObrigatoria'],
      user: UserModel.fromJson(json['usuario']),
    );
  }

  /// Mesma sessão com o novo par de tokens (renovação), mantendo Usuário e a troca de senha.
  AuthModel withTokens({required String token, required String refreshToken}) {
    return AuthModel(
      token: token,
      refreshToken: refreshToken,
      needChangePassword: needChangePassword,
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data.addAll({
      'token': token,
      if (refreshToken != null) 'refreshToken': refreshToken,
      'trocaSenhaObrigatoria': needChangePassword,
      'usuario': user.toJson(),
    });

    return data;
  }
}
