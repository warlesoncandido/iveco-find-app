import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/modules/auth/controllers/auth_controller.dart';
import 'package:iveco_find/src/modules/auth/controllers/change_password_controller.dart';
import 'package:iveco_find/src/shared/repositories/auth_repository.dart';

import '../user/fakes.dart';

void main() {
  late FakeClientDio dio;
  late FakeLocalStorage storage;
  late AuthRepository repository;
  late ChangePasswordController controller;

  final loginResponse = {
    'token': 'tok',
    'trocaSenhaObrigatoria': true,
    'usuario': {
      'id': 'u1',
      'nome': 'Maria',
      'email': 'maria@iveco.com',
      'perfil': 'GESTOR',
    },
  };

  Map<String, dynamic> storedAuth() =>
      json.decode(storage.values['auth']!) as Map<String, dynamic>;

  setUp(() {
    dio = FakeClientDio();
    storage = FakeLocalStorage();
    repository = AuthRepository(dio: dio);
    controller = ChangePasswordController(
      storage: storage,
      repository: repository,
    );
    storage.values['auth'] = json.encode(loginResponse);
  });

  group('AuthRepository.changePassword', () {
    test('POST /api/v1/auth/senha autenticado com senhaAtual e novaSenha', () async {
      final result = await repository.changePassword(
        currentPassword: 'Prov@123',
        newPassword: 'Nova@1234',
      );
      expect(result.isRight(), isTrue);
      final call = dio.calls.single;
      expect(call.method, 'POST');
      expect(call.path, '/api/v1/auth/senha');
      expect(call.isAuth, isTrue);
      expect(call.data, {'senhaAtual': 'Prov@123', 'novaSenha': 'Nova@1234'});
    });

    test('422 SENHA_ATUAL_INCORRETA vira Failure com detail e codigo', () async {
      dio.error = problemDetails(
        422,
        'SENHA_ATUAL_INCORRETA',
        'Senha atual incorreta',
      );
      final result = await repository.changePassword(
        currentPassword: 'errada',
        newPassword: 'Nova@1234',
      );
      final failure = result.fold((l) => l, (r) => null)!;
      expect(failure.message, 'Senha atual incorreta');
      expect(failure.code, 'SENHA_ATUAL_INCORRETA');
    });
  });

  group('ChangePasswordController', () {
    test('sucesso: marca a troca como feita no auth salvo e limpa o form', () async {
      controller.currentPasswordController.text = 'Prov@123';
      controller.newPasswordController.text = 'Nova@1234';
      controller.confirmPasswordController.text = 'Nova@1234';
      var ok = false;

      await controller.changePassword(
        onSuccess: () => ok = true,
        onError: (_) => fail('não deveria falhar'),
      );

      expect(ok, isTrue);
      expect(storedAuth()['trocaSenhaObrigatoria'], isFalse);
      expect(storedAuth()['token'], 'tok');
      expect(storedAuth()['usuario']['perfil'], 'GESTOR');
      expect(controller.currentPasswordController.text, isEmpty);
      expect(controller.isLoading, isFalse);
    });

    test('erro: chama onError com o detail e mantém a troca pendente', () async {
      dio.error = problemDetails(
        422,
        'NOVA_SENHA_IGUAL_ATUAL',
        'A nova senha deve ser diferente da atual',
      );
      String? message;

      await controller.changePassword(
        onSuccess: () => fail('não deveria ter sucesso'),
        onError: (m) => message = m,
      );

      expect(message, 'A nova senha deve ser diferente da atual');
      expect(storedAuth()['trocaSenhaObrigatoria'], isTrue);
      expect(controller.isLoading, isFalse);
    });

    test('logout chama a API e remove o auth salvo', () async {
      var left = false;
      await controller.logout(onSuccess: () => left = true);
      expect(left, isTrue);
      expect(dio.calls.single.path, '/api/v1/auth/logout');
      expect(storage.values.containsKey('auth'), isFalse);
    });
  });

  group('AuthController', () {
    late AuthController auth;
    setUp(() => auth = AuthController(storage: storage, repository: repository));

    test('login com Senha Provisória → onSuccess(true) e auth já salvo', () async {
      storage.values.clear();
      dio.response = loginResponse;
      bool? mustChange;

      await auth.auth(onSuccess: (v) => mustChange = v, onError: () {});

      expect(mustChange, isTrue);
      expect(storedAuth()['token'], 'tok');
    });

    test('mustChangePassword lê o auth salvo', () async {
      expect(await auth.mustChangePassword(), isTrue);
      storage.values['auth'] = json.encode({
        ...loginResponse,
        'trocaSenhaObrigatoria': false,
      });
      expect(await auth.mustChangePassword(), isFalse);
      storage.values.clear();
      expect(await auth.mustChangePassword(), isFalse);
    });
  });
}
