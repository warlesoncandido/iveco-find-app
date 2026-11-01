import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iveco_find/src/shared/enums/user_profile.dart';
import 'package:iveco_find/src/shared/models/pagination_model.dart';
import 'package:iveco_find/src/shared/models/user_model.dart';
import 'package:iveco_find/src/shared/repositories/user_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class UserController extends ChangeNotifier {
  final UserRepository repository;

  UserController({required this.repository});

  Behaviour behaviourPage = Behaviour.loading;

  PaginationModel? pagination;

  int currentPage = 1;

  String query = '';

  UserProfile? perfil;

  /// `null` = todos; `true` = só ativos; `false` = só inativos.
  bool? ativo;

  Timer? _debounce;

  /// Descarta respostas de cargas mais antigas que chegam fora de ordem.
  int _seq = 0;

  List<UserModel> get users {
    if (pagination != null) {
      return pagination!.items as List<UserModel>;
    }
    return [];
  }

  void setCurrentPage(int page) {
    currentPage = page;
    loadUsers();
  }

  void search(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      query = value;
      currentPage = 1;
      loadUsers();
    });
  }

  void changePerfil(UserProfile? value) {
    perfil = value;
    currentPage = 1;
    loadUsers();
  }

  void changeAtivo(bool? value) {
    ativo = value;
    currentPage = 1;
    loadUsers();
  }

  Future<void> loadUsers() async {
    final seq = ++_seq;
    behaviourPage = Behaviour.loading;
    notifyListeners();
    final result = await repository.getUsers(
      page: currentPage,
      query: query,
      perfil: perfil?.value,
      ativo: ativo,
    );
    if (seq != _seq) return;
    result.fold(
      (l) {
        behaviourPage = Behaviour.error;
        notifyListeners();
      },
      (r) {
        pagination = r;
        behaviourPage = Behaviour.success;
        notifyListeners();
      },
    );
  }
}
