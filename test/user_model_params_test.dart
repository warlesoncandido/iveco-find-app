import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/shared/models/auth_model.dart';
import 'package:iveco_find/src/shared/models/provisional_password_model.dart';
import 'package:iveco_find/src/shared/models/user_model.dart';
import 'package:iveco_find/src/shared/params/user_params.dart';

void main() {
  final base = {
    'id': '7b0f8c1e-1111-4222-8333-944455556666',
    'nome': 'Maria',
    'email': 'maria@iveco.com',
    'perfil': 'GESTOR',
  };

  group('UserModel.fromJson', () {
    test('com ativo e trocaSenhaObrigatoria', () {
      final user = UserModel.fromJson({
        ...base,
        'ativo': false,
        'trocaSenhaObrigatoria': true,
      });
      expect(user.ativo, isFalse);
      expect(user.trocaSenhaObrigatoria, isTrue);
      expect(user.toJson()['ativo'], isFalse);
      expect(user.toJson()['trocaSenhaObrigatoria'], isTrue);
    });

    test('sem ativo (auth salvo antes da mudança) usa os defaults', () {
      final user = UserModel.fromJson(base);
      expect(user.ativo, isTrue);
      expect(user.trocaSenhaObrigatoria, isFalse);
      expect(user.perfil, 'GESTOR');
    });

    test('AuthModel antigo continua sendo lido', () {
      final auth = AuthModel.fromJson({
        'token': 'abc',
        'trocaSenhaObrigatoria': false,
        'usuario': base,
      });
      expect(auth.user.nome, 'Maria');
      expect(auth.user.ativo, isTrue);
    });
  });

  group('ProvisionalPasswordModel.fromJson', () {
    test('raiz do SenhaRedefinida', () {
      final model = ProvisionalPasswordModel.fromJson({
        'senhaProvisoria': 'Abc123!x',
        'senhaProvisoriaExpiraEm': '2026-11-04T12:00:00.000Z',
      });
      expect(model.senhaProvisoria, 'Abc123!x');
      expect(model.senhaProvisoriaExpiraEm, DateTime.utc(2026, 11, 4, 12));
    });

    test('raiz do UsuarioCriado (com usuario)', () {
      final model = ProvisionalPasswordModel.fromJson({
        'usuario': {...base, 'ativo': true, 'trocaSenhaObrigatoria': true},
        'senhaProvisoria': 'Xyz987!k',
        'senhaProvisoriaExpiraEm': '2026-11-04T12:00:00.000Z',
      });
      expect(model.senhaProvisoria, 'Xyz987!k');
      expect(model.senhaProvisoriaExpiraEm.isUtc, isTrue);
    });
  });

  group('UserParams', () {
    test('toCreateJson só com nome, email e perfil', () {
      final params = UserParams(
        nome: ' João ',
        email: ' joao@iveco.com ',
        perfil: 'OPERACIONAL',
        ativo: false,
      );
      expect(params.toCreateJson(), {
        'nome': 'João',
        'email': 'joao@iveco.com',
        'perfil': 'OPERACIONAL',
      });
    });

    final original = UserModel.fromJson({...base, 'ativo': true});

    test('toUpdateJson vazio quando nada muda', () {
      final params = UserParams(
        nome: 'Maria',
        email: 'maria@iveco.com',
        perfil: 'GESTOR',
        ativo: true,
      );
      expect(params.toUpdateJson(original), isEmpty);
    });

    test('toUpdateJson só com campos alterados', () {
      expect(
        UserParams(
          nome: 'Maria',
          email: 'maria@iveco.com',
          perfil: 'ADMINISTRADOR',
          ativo: true,
        ).toUpdateJson(original),
        {'perfil': 'ADMINISTRADOR'},
      );
      expect(
        UserParams(
          nome: 'Maria Silva',
          email: 'outro@iveco.com',
          perfil: 'GESTOR',
          ativo: false,
        ).toUpdateJson(original),
        {'nome': 'Maria Silva', 'ativo': false},
      );
    });
  });
}
