import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/services/i_local_storage.dart';
import 'package:iveco_find/src/shared/enums/local_storage_keys.dart';
import 'package:iveco_find/src/shared/enums/permission.dart';
import 'package:iveco_find/src/shared/enums/user_profile.dart';
import 'package:iveco_find/src/shared/models/auth_model.dart';
import 'package:iveco_find/src/shared/repositories/auth_repository.dart';

class HomeController extends ChangeNotifier {
  final AuthRepository authRepository;
  final LocalStorage storage;
  HomeController({required this.authRepository, required this.storage});

  final pageController = PageController();
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  /// Perfil do Usuário logado (lido do `auth` no storage).
  String? perfil;

  bool get isAdmin => perfil == UserProfile.administrador.value;

  /// Esconde da UI o que a API recusaria com 403 para o Perfil logado.
  bool can(Permission permission) =>
      Permission.forProfile(perfil).contains(permission);

  Future<void> loadPerfil() async {
    final auth = await storage.getString(LocalStorageKeys.auth.name());
    String? value;
    if (auth != null && auth.isNotEmpty) {
      value = AuthModel.fromJson(json.decode(auth)).user.perfil;
    }
    perfil = value;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  Future<void> logout({required Function() onSuccess}) async {
    await authRepository.logout();

    storage.remove(LocalStorageKeys.auth.name());
    perfil = null;
    _selectedIndex = 0;
    notifyListeners();
    onSuccess();
  }
}
