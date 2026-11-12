import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/modules/home/pages/dashboard/controllers/dashboard_controller.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

import 'fakes.dart';

void main() {
  late FakeDashboardRepository repository;
  late DashboardController controller;

  setUp(() {
    repository = FakeDashboardRepository();
    controller = DashboardController(repository: repository);
  });

  test(
    'começa em loading; sucesso carrega as 2 chamadas e ordena Localidades por quantidade desc',
    () async {
      repository.locations = [
        locationJson('a', 'Alfa', 1),
        locationJson('b', 'Beta', 3),
        locationJson('c', 'Gama', 3),
        locationJson('d', 'Delta', 2),
      ];
      final states = <Behaviour>[];
      controller.addListener(() => states.add(controller.behaviourPage));
      expect(controller.behaviourPage, Behaviour.loading);

      await controller.load();

      expect(states, [Behaviour.loading, Behaviour.success]);
      expect(repository.summaryCalls, 1);
      expect(repository.locationCalls, 1);
      expect(controller.summary!.total, 6);
      // Empate (Beta/Gama com 3) mantém a ordem da API.
      expect(controller.locations.map((l) => l.id), ['b', 'c', 'd', 'a']);
    },
  );

  test('falha no resumo → error', () async {
    repository.summaryFailure = Failure(message: 'x');
    await controller.load();
    expect(controller.behaviourPage, Behaviour.error);
  });

  test('falha nas Localidades → error', () async {
    repository.locationFailure = Failure(message: 'x');
    await controller.load();
    expect(controller.behaviourPage, Behaviour.error);
  });

  test('retry refaz as 2 chamadas e sai do erro', () async {
    repository.locationFailure = Failure(message: 'x');
    await controller.load();
    expect(controller.behaviourPage, Behaviour.error);

    repository.locationFailure = null;
    await controller.load();
    expect(controller.behaviourPage, Behaviour.success);
    expect(repository.summaryCalls, 2);
    expect(repository.locationCalls, 2);
  });

  test(
    'resposta atrasada de uma carga antiga não sobrescreve a mais nova',
    () async {
      final gate = Completer<void>();
      repository
        ..summaryGate = gate
        ..summaryFailure = Failure(message: 'x');
      final first = controller.load();

      repository
        ..summaryGate = null
        ..summaryFailure = null
        ..summary = summaryJson(disponivel: 10, emUso: 0, emManutencao: 0);
      await controller.load();
      expect(controller.behaviourPage, Behaviour.success);

      gate.complete();
      await first;

      expect(controller.behaviourPage, Behaviour.success);
      expect(controller.summary!.total, 10);
      expect(repository.summaryCalls, 2);
    },
  );
}
