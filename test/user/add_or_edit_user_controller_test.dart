import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/modules/home/pages/user/controllers/add_or_edit_user_controller.dart';
import 'package:iveco_find/src/shared/enums/user_profile.dart';
import 'package:iveco_find/src/shared/models/provisional_password_model.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

import 'fakes.dart';

void main() {
  late FakeUserRepository repository;
  late AddOrEditUserController controller;

  ProvisionalPasswordModel? created;
  var updated = 0;
  String? error;

  Future<void> save() => controller.save(
    onCreated: (p) => created = p,
    onUpdated: () => updated++,
    onError: (m) => error = m,
  );

  setUp(() {
    repository = FakeUserRepository();
    controller = AddOrEditUserController(repository: repository);
    created = null;
    updated = 0;
    error = null;
  });

  group('Criar', () {
    setUp(() async {
      await controller.fillFields(null);
      controller.nameController.text = 'João';
      controller.emailController.text = 'joao@iveco.com';
      controller.changePerfil(UserProfile.operacional);
    });

    test('chama createUser e onCreated com a senha', () async {
      await save();
      final params = repository.createCalls.single;
      expect(params.toCreateJson(), {
        'nome': 'João',
        'email': 'joao@iveco.com',
        'perfil': 'OPERACIONAL',
      });
      expect(created, same(password));
      expect(error, isNull);
      expect(updated, 0);
    });

    test('409 EMAIL_DUPLICADO → onError com o detail', () async {
      repository.failure = Failure(
        message: 'Já existe um Usuário com este e-mail.',
        code: 'EMAIL_DUPLICADO',
      );
      await save();
      expect(error, 'Já existe um Usuário com este e-mail.');
      expect(created, isNull);
    });
  });

  group('Editar', () {
    setUp(() async {
      repository.stored = user(id: 'u1', perfil: 'GESTOR', ativo: true);
      await controller.fillFields(user(id: 'u1'));
    });

    test('fillFields carrega via getUser', () {
      expect(repository.getUserCalls, ['u1']);
      expect(controller.isEditing, isTrue);
      expect(controller.nameController.text, 'Maria');
      expect(controller.emailController.text, 'maria@iveco.com');
      expect(controller.perfil, UserProfile.gestor);
      expect(controller.active, isTrue);
    });

    test('sem mudança → onUpdated sem chamar a API', () async {
      await save();
      expect(updated, 1);
      expect(repository.updateCalls, isEmpty);
    });

    test('com mudança → updateUser só com os campos alterados', () async {
      controller.changePerfil(UserProfile.administrador);
      controller.changeActive(false);
      await save();
      final call = repository.updateCalls.single;
      expect(call.key, 'u1');
      expect(call.value, {'perfil': 'ADMINISTRADOR', 'ativo': false});
      expect(updated, 1);
    });

    test('422 → onError com o detail', () async {
      repository.failure = Failure(
        message: 'Não é possível desativar a si mesmo.',
        code: 'AUTO_DESATIVACAO_PROIBIDA',
      );
      controller.changeActive(false);
      await save();
      expect(error, 'Não é possível desativar a si mesmo.');
      expect(updated, 0);
    });

    test('resetPassword sucesso → onSuccess com a senha', () async {
      ProvisionalPasswordModel? result;
      await controller.resetPassword(
        onSuccess: (p) => result = p,
        onError: (m) => error = m,
      );
      expect(repository.resetCalls, ['u1']);
      expect(result, same(password));
      expect(error, isNull);
      expect(controller.resettingPassword, isFalse);
    });

    test('resetPassword erro → onError com o detail', () async {
      repository.failure = Failure(
        message: 'Use a troca de senha.',
        code: 'REDEFINICAO_PROPRIA_PROIBIDA',
      );
      ProvisionalPasswordModel? result;
      await controller.resetPassword(
        onSuccess: (p) => result = p,
        onError: (m) => error = m,
      );
      expect(result, isNull);
      expect(error, 'Use a troca de senha.');
      expect(controller.resettingPassword, isFalse);
    });

    test('clearFields volta ao estado de cadastro', () {
      controller.clearFields();
      expect(controller.isEditing, isFalse);
      expect(controller.user, isNull);
      expect(controller.perfil, isNull);
      expect(controller.nameController.text, isEmpty);
    });
  });

  group('Carga da edição', () {
    test('getUser com erro → Behaviour.error e user == null', () async {
      repository.failure = Failure(message: 'Falha ao buscar usuário.');
      await controller.fillFields(user(id: 'u1'));
      expect(controller.behaviourPage, Behaviour.error);
      expect(controller.user, isNull);
    });

    test('resposta atrasada após clearFields é descartada', () async {
      repository.getUserGate = Completer<void>();
      final pending = controller.fillFields(user(id: 'u1'));
      controller.clearFields();
      repository.getUserGate!.complete();
      await pending;
      expect(controller.user, isNull);
      expect(controller.isEditing, isFalse);
      expect(controller.nameController.text, isEmpty);
      expect(controller.behaviourPage, Behaviour.success);
    });
  });
}
