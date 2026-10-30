import 'package:iveco_find/src/shared/models/user_model.dart';

class AuthModel {
  final String token;
  final bool needChangePassword;
  final UserModel user;

  AuthModel({
    required this.token,
    required this.needChangePassword,
    required this.user,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      token: json['token'],
      needChangePassword: json['trocaSenhaObrigatoria'],
      user: UserModel.fromJson(json['usuario']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data.addAll({
      'token': token,
      'trocaSenhaObrigatoria': needChangePassword,
      'usuario': user.toJson(),
    });

    return data;
  }
}
