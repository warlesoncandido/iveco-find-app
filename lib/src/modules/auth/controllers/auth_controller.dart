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
  final passwordController = TextEditingController(text: 'Admin@1234');

  bool isLoading = false;

  Future<void> auth({
    required Function() onSuccess,
    required Function() onError,
  }) async {
    isLoading = true;
    notifyListeners();

    final result = await repository.auth(
      email: emailController.text,
      password: passwordController.text,
    );
    result.fold(
      (l) {
        onError();
        isLoading = false;
        notifyListeners();
      },
      (r) {
        saveUser(r);
        onSuccess();
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> saveUser(AuthModel auth) async {
    storage.setString(LocalStorageKeys.auth.name(), json.encode(auth.toJson()));
  }

  Future<bool> isAuthenticated() async {
    final result = await storage.getString(LocalStorageKeys.auth.name());
    return result != null;
  }
}
