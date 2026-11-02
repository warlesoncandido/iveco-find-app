import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/services/i_local_storage.dart';
import 'package:iveco_find/src/shared/enums/local_storage_keys.dart';
import 'package:iveco_find/src/shared/models/auth_model.dart';
import 'package:iveco_find/src/shared/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository repository;
  final LocalStorage storage;
  AuthController({required this.storage, required this.repository});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final emailController = TextEditingController(text: 'admin@teste.com');
  final passwordController = TextEditingController(text: 'Admin@12345');

  bool isLoading = false;

  /// `onSuccess` recebe `true` quando o Usuário entrou com Senha Provisória
  /// e precisa trocá-la antes de usar o app.
  Future<void> auth({
    required Function(bool mustChangePassword) onSuccess,
    required Function() onError,
  }) async {
    isLoading = true;
    notifyListeners();

    final result = await repository.auth(
      email: emailController.text,
      password: passwordController.text,
    );
    await result.fold(
      (l) async {
        onError();
        isLoading = false;
        notifyListeners();
      },
      (r) async {
        await saveUser(r);
        onSuccess(r.needChangePassword);
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> saveUser(AuthModel auth) async {
    await storage.setString(
      LocalStorageKeys.auth.name(),
      json.encode(auth.toJson()),
    );
  }

  Future<bool> isAuthenticated() async {
    final result = await storage.getString(LocalStorageKeys.auth.name());
    return result != null;
  }

  /// Login salvo ainda com a troca da Senha Provisória pendente.
  Future<bool> mustChangePassword() async {
    final result = await storage.getString(LocalStorageKeys.auth.name());
    if (result == null) return false;
    return AuthModel.fromJson(json.decode(result)).needChangePassword;
  }
}
