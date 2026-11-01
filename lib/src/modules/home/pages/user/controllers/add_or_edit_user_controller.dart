import 'package:flutter/material.dart';
import 'package:iveco_find/src/shared/enums/user_profile.dart';
import 'package:iveco_find/src/shared/models/provisional_password_model.dart';
import 'package:iveco_find/src/shared/models/user_model.dart';
import 'package:iveco_find/src/shared/params/user_params.dart';
import 'package:iveco_find/src/shared/repositories/user_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';

class AddOrEditUserController extends ChangeNotifier {
  final UserRepository repository;

  AddOrEditUserController({required this.repository});

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  /// Estado do botão salvar.
  Behaviour? behaviour;

  /// Estado da carga inicial (edição: `GET /usuarios/{id}`).
  Behaviour behaviourPage = Behaviour.success;

  bool resettingPassword = false;

  UserProfile? perfil;

  bool active = true;

  /// Usuário original (edição). `null` = cadastro.
  UserModel? user;

  String? _userId;

  bool get isEditing => _userId != null;

  Future<void> fillFields(UserModel? value) async {
    clearFields();
    if (value == null) {
      notifyListeners();
      return;
    }
    _userId = value.id;
    await load();
  }

  Future<void> load() async {
    final id = _userId;
    if (id == null) return;
    behaviourPage = Behaviour.loading;
    notifyListeners();

    final result = await repository.getUser(id);
    // Resposta atrasada de um usuário que não está mais na tela.
    if (_userId != id) return;
    result.fold(
      (l) {
        behaviourPage = Behaviour.error;
      },
      (r) {
        user = r;
        nameController.text = r.nome;
        emailController.text = r.email;
        perfil = UserProfile.fromValue(r.perfil);
        active = r.ativo;
        behaviourPage = Behaviour.success;
      },
    );
    notifyListeners();
  }

  void changePerfil(UserProfile? value) {
    perfil = value;
    notifyListeners();
  }

  void changeActive(bool value) {
    active = value;
    notifyListeners();
  }

  /// Cadastro: `onCreated` recebe a Senha Provisória.
  /// Edição: `onUpdated` (também quando nada mudou — não chama a API).
  Future<void> save({
    required void Function(ProvisionalPasswordModel password) onCreated,
    required void Function() onUpdated,
    required void Function(String message) onError,
  }) async {
    final params = UserParams(
      nome: nameController.text,
      email: emailController.text,
      perfil: perfil!.value,
      ativo: active,
    );

    if (user != null) {
      final json = params.toUpdateJson(user!);
      if (json.isEmpty) {
        onUpdated();
        return;
      }
      behaviour = Behaviour.loading;
      notifyListeners();
      final result = await repository.updateUser(user!.id, json);
      behaviour = null;
      notifyListeners();
      result.fold((l) => onError(l.message!), (r) => onUpdated());
      return;
    }

    behaviour = Behaviour.loading;
    notifyListeners();
    final result = await repository.createUser(params);
    behaviour = null;
    notifyListeners();
    result.fold((l) => onError(l.message!), (r) => onCreated(r));
  }

  Future<void> resetPassword({
    required void Function(ProvisionalPasswordModel password) onSuccess,
    required void Function(String message) onError,
  }) async {
    if (user == null) return;
    resettingPassword = true;
    notifyListeners();
    final result = await repository.resetPassword(user!.id);
    resettingPassword = false;
    notifyListeners();
    result.fold((l) => onError(l.message!), (r) => onSuccess(r));
  }

  void clearFields() {
    nameController.clear();
    emailController.clear();
    perfil = null;
    active = true;
    user = null;
    _userId = null;
    behaviour = null;
    behaviourPage = Behaviour.success;
    resettingPassword = false;
  }
}
