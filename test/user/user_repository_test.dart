import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/shared/models/user_model.dart';
import 'package:iveco_find/src/shared/params/user_params.dart';
import 'package:iveco_find/src/shared/repositories/user_repository.dart';

import 'fakes.dart';

void main() {
  late FakeClientDio dio;
  late UserRepository repository;

  final userJson = {
    'id': 'u1',
    'nome': 'Maria',
    'email': 'maria@iveco.com',
    'perfil': 'GESTOR',
    'ativo': false,
    'trocaSenhaObrigatoria': true,
    'criadoEm': '2026-11-01T10:00:00.000Z',
    'atualizadoEm': '2026-11-01T10:00:00.000Z',
  };
  final passwordJson = {
    'senhaProvisoria': 'Abc123!x',
    'senhaProvisoriaExpiraEm': '2026-11-04T12:00:00.000Z',
  };

  setUp(() {
    dio = FakeClientDio();
    repository = UserRepository(dio: dio);
  });

  group('getUsers (Listar / Buscar-filtrar)', () {
    setUp(() {
      dio.response = {
        'total': 1,
        'pagina': 1,
        'tamanhoPagina': 25,
        'itens': [userJson],
      };
    });

    test('sem filtros: só pagina, tamanhoPagina=25 e ordem=asc', () async {
      final result = await repository.getUsers(page: 1);

      final call = dio.calls.single;
      expect(call.method, 'GET');
      expect(call.path, '/api/v1/usuarios');
      expect(call.isAuth, isTrue);
      expect(call.queryParameters, {
        'pagina': 1,
        'tamanhoPagina': 25,
        'ordem': 'asc',
      });

      final page = result.getOrElse(() => throw 'falhou');
      expect(page.total, 1);
      final items = page.items as List<UserModel>;
      expect(items.single.nome, 'Maria');
      expect(items.single.ativo, isFalse);
      expect(items.single.trocaSenhaObrigatoria, isTrue);
    });

    test('busca em branco não envia q', () async {
      await repository.getUsers(page: 1, query: '   ');
      expect(dio.calls.single.queryParameters!.containsKey('q'), isFalse);
    });

    test('envia q, perfil e ativo quando preenchidos', () async {
      await repository.getUsers(
        page: 3,
        query: ' mar ',
        perfil: 'ADMINISTRADOR',
        ativo: false,
      );
      expect(dio.calls.single.queryParameters, {
        'pagina': 3,
        'tamanhoPagina': 25,
        'ordem': 'asc',
        'q': 'mar',
        'perfil': 'ADMINISTRADOR',
        'ativo': 'false',
      });
    });

    test('erro sem Problem Details usa a mensagem padrão', () async {
      dio.error = Exception('rede');
      final result = await repository.getUsers(page: 1);
      final failure = result.fold((l) => l, (r) => throw 'devia falhar');
      expect(failure.message, 'Falha ao buscar usuários.');
      expect(failure.code, isNull);
    });
  });

  test('getUser faz GET /usuarios/{id}', () async {
    dio.response = userJson;
    final result = await repository.getUser('u1');
    expect(dio.calls.single.method, 'GET');
    expect(dio.calls.single.path, '/api/v1/usuarios/u1');
    expect(result.getOrElse(() => throw 'falhou').email, 'maria@iveco.com');
  });

  group('createUser (Criar)', () {
    final params = UserParams(
      nome: 'João',
      email: 'joao@iveco.com',
      perfil: 'OPERACIONAL',
    );

    test('POST com nome/email/perfil e devolve a senha provisória', () async {
      dio.response = {'usuario': userJson, ...passwordJson};
      final result = await repository.createUser(params);

      final call = dio.calls.single;
      expect(call.method, 'POST');
      expect(call.path, '/api/v1/usuarios');
      expect(call.data, {
        'nome': 'João',
        'email': 'joao@iveco.com',
        'perfil': 'OPERACIONAL',
      });
      final password = result.getOrElse(() => throw 'falhou');
      expect(password.senhaProvisoria, 'Abc123!x');
      expect(password.senhaProvisoriaExpiraEm, DateTime.utc(2026, 11, 4, 12));
    });

    test('409 EMAIL_DUPLICADO → Failure com detail e codigo', () async {
      dio.error = problemDetails(
        409,
        'EMAIL_DUPLICADO',
        'Já existe um Usuário com este e-mail.',
      );
      final result = await repository.createUser(params);
      final failure = result.fold((l) => l, (r) => throw 'devia falhar');
      expect(failure.message, 'Já existe um Usuário com este e-mail.');
      expect(failure.code, 'EMAIL_DUPLICADO');
    });
  });

  group('updateUser (Editar)', () {
    test('PATCH /usuarios/{id} só com o json informado', () async {
      dio.response = userJson;
      final result = await repository.updateUser('u1', {'perfil': 'GESTOR'});

      final call = dio.calls.single;
      expect(call.method, 'PATCH');
      expect(call.path, '/api/v1/usuarios/u1');
      expect(call.data, {'perfil': 'GESTOR'});
      expect(result.isRight(), isTrue);
    });

    for (final codigo in [
      'AUTO_DESATIVACAO_PROIBIDA',
      'MINIMO_DOIS_ADMINISTRADORES',
    ]) {
      test('422 $codigo → Failure com detail e codigo', () async {
        dio.error = problemDetails(422, codigo, 'Detalhe de $codigo');
        final result = await repository.updateUser('u1', {'ativo': false});
        final failure = result.fold((l) => l, (r) => throw 'devia falhar');
        expect(failure.message, 'Detalhe de $codigo');
        expect(failure.code, codigo);
      });
    }

    test('erro de validação com campos usa o primeiro campo', () async {
      final error = problemDetails(400, 'VALIDACAO', 'Dados inválidos.');
      (error.response!.data as Map)['campos'] = [
        {'campo': 'nome', 'mensagem': 'obrigatório'},
      ];
      dio.error = error;
      final result = await repository.updateUser('u1', {'nome': ''});
      final failure = result.fold((l) => l, (r) => throw 'devia falhar');
      expect(failure.message, 'nome: obrigatório');
      expect(failure.code, 'VALIDACAO');
    });
  });

  group('resetPassword (Redefinir senha)', () {
    test('POST /usuarios/{id}/senha-provisoria devolve a senha', () async {
      dio.response = passwordJson;
      final result = await repository.resetPassword('u1');

      final call = dio.calls.single;
      expect(call.method, 'POST');
      expect(call.path, '/api/v1/usuarios/u1/senha-provisoria');
      expect(
        result.getOrElse(() => throw 'falhou').senhaProvisoria,
        'Abc123!x',
      );
    });

    test('422 REDEFINICAO_PROPRIA_PROIBIDA → Failure com detail', () async {
      dio.error = problemDetails(
        422,
        'REDEFINICAO_PROPRIA_PROIBIDA',
        'Use a troca de senha para a sua própria conta.',
      );
      final result = await repository.resetPassword('u1');
      final failure = result.fold((l) => l, (r) => throw 'devia falhar');
      expect(failure.message, 'Use a troca de senha para a sua própria conta.');
      expect(failure.code, 'REDEFINICAO_PROPRIA_PROIBIDA');
    });
  });
}
