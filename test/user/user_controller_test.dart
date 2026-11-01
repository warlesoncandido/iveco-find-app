import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/modules/home/pages/user/controllers/user_controller.dart';
import 'package:iveco_find/src/shared/enums/user_profile.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

import 'fakes.dart';

void main() {
  late FakeUserRepository repository;
  late UserController controller;

  setUp(() {
    repository = FakeUserRepository();
    controller = UserController(repository: repository);
  });

  test('loadUsers: página 1 sem filtros e sucesso', () async {
    await controller.loadUsers();
    final call = repository.getUsersCalls.single;
    expect(call.page, 1);
    expect(call.query, '');
    expect(call.perfil, isNull);
    expect(call.ativo, isNull);
    expect(controller.behaviourPage, Behaviour.success);
    expect(controller.users.single.nome, 'Maria');
  });

  test('erro → Behaviour.error', () async {
    repository.failure = Failure(message: 'x');
    await controller.loadUsers();
    expect(controller.behaviourPage, Behaviour.error);
  });

  test('setCurrentPage recarrega com a nova página', () async {
    controller.setCurrentPage(3);
    await Future<void>.delayed(Duration.zero);
    expect(controller.currentPage, 3);
    expect(repository.getUsersCalls.single.page, 3);
  });

  test('changePerfil volta à página 1 e recarrega com o perfil', () async {
    controller.currentPage = 4;
    controller.changePerfil(UserProfile.gestor);
    await Future<void>.delayed(Duration.zero);
    expect(controller.currentPage, 1);
    final call = repository.getUsersCalls.single;
    expect(call.page, 1);
    expect(call.perfil, 'GESTOR');
  });

  test('changeAtivo volta à página 1 e recarrega com a situação', () async {
    controller.currentPage = 2;
    controller.changeAtivo(false);
    await Future<void>.delayed(Duration.zero);
    expect(controller.currentPage, 1);
    final call = repository.getUsersCalls.single;
    expect(call.page, 1);
    expect(call.ativo, isFalse);
  });

  // testWidgets roda em FakeAsync: tester.pump avança o relógio do Timer.
  testWidgets('search: debounce de 400 ms e volta à página 1', (tester) async {
    controller.currentPage = 5;

    controller.search('ma');
    await tester.pump(const Duration(milliseconds: 200));
    controller.search('mar');
    await tester.pump(const Duration(milliseconds: 399));
    expect(repository.getUsersCalls, isEmpty);

    await tester.pump(const Duration(milliseconds: 1));
    expect(repository.getUsersCalls, hasLength(1));
    final call = repository.getUsersCalls.single;
    expect(call.query, 'mar');
    expect(call.page, 1);
    expect(controller.currentPage, 1);
  });

  test('respostas fora de ordem: vale a carga mais recente', () async {
    final slow = Completer<void>();
    repository.getUsersGate = slow;
    final first = controller.loadUsers(); // página 1 (Maria), fica pendente
    repository.getUsersGate = null;
    repository.items = [user(id: 'u2', nome: 'Novo')];
    controller.currentPage = 2;
    await controller.loadUsers(); // responde antes
    slow.complete();
    await first;
    expect(controller.users.single.nome, 'Novo');
    expect(controller.pagination!.page, 2);
    expect(controller.behaviourPage, Behaviour.success);
  });
}
