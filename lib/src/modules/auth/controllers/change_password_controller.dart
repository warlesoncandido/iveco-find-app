import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/services/i_local_storage.dart';
import 'package:iveco_find/src/shared/enums/local_storage_keys.dart';
import 'package:iveco_find/src/shared/models/auth_model.dart';
import 'package:iveco_find/src/shared/repositories/auth_repository.dart';

/// Troca obrigatória da Senha Provisória: enquanto não for feita, a API
/// responde 403 TROCA_SENHA_OBRIGATORIA em todas as outras rotas.
class ChangePasswordController extends ChangeNotifier {
  final AuthRepository repository;
  final LocalStorage storage;
  ChangePasswordController({required this.storage, required this.repository});

  final formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> changePassword({
    required void Function() onSuccess,
    required void Function(String message) onError,
  }) async {
    isLoading = true;
    notifyListeners();

    final result = await repository.changePassword(
      currentPassword: currentPasswordController.text,
      newPassword: newPasswordController.text,
    );

    await result.fold(
      (l) async {
        isLoading = false;
        notifyListeners();
        onError(l.message!);
      },
      (r) async {
        await _markPasswordChanged();
        clearFields();
        isLoading = false;
        notifyListeners();
        onSuccess();
      },
    );
  }

  /// Atualiza o `auth` salvo para não pedir a troca de novo ao reabrir o app.
  Future<void> _markPasswordChanged() async {
    final raw = await storage.getString(LocalStorageKeys.auth.name());
    if (raw == null) return;
    final auth = AuthModel.fromJson(json.decode(raw));
    final updated = AuthModel(
      token: auth.token,
      needChangePassword: false,
      user: auth.user,
    );
    await storage.setString(
      LocalStorageKeys.auth.name(),
      json.encode(updated.toJson()),
    );
  }

  Future<void> logout({required void Function() onSuccess}) async {
    await repository.logout();
    await storage.remove(LocalStorageKeys.auth.name());
    clearFields();
    onSuccess();
  }

  void clearFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }
}
