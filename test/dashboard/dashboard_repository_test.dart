import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/shared/enums/active_status.dart';
import 'package:iveco_find/src/shared/repositories/dashboard_repository.dart';

import '../user/fakes.dart';
import 'fakes.dart';

void main() {
  late FakeClientDio dio;
  late DashboardRepository repository;

  setUp(() {
    dio = FakeClientDio();
    repository = DashboardRepository(dio: dio);
  });

  group('getSummary', () {
    test('GET /api/v1/dashboard/resumo autenticado e faz o parse', () async {
      dio.response = summaryJson();
      final result = await repository.getSummary();

      final call = dio.calls.single;
      expect(call.method, 'GET');
      expect(call.path, '/api/v1/dashboard/resumo');
      expect(call.isAuth, isTrue);

      final s = result.getOrElse(() => throw 'falhou');
      expect(s.total, 6);
      expect(s.inUse, 3);
      expect(s.byStatus, {
        ActiveStatus.disponivel: 2,
        ActiveStatus.emUso: 3,
        ActiveStatus.emManutencao: 1,
        ActiveStatus.baixado: 1,
      });
      expect(s.byType.map((t) => [t.id, t.nome, t.quantidade]), [
        ['t1', 'Furadeira', 4],
        ['t2', 'Notebook', 2],
      ]);
      expect(s.totalValue, '1234.50');
      expect(s.withoutValue, 1);
    });

    test('Status ausente na resposta vira 0', () async {
      dio.response = {...emptySummaryJson, 'porStatus': <String, dynamic>{}};
      final s = (await repository.getSummary()).getOrElse(() => throw 'falhou');
      expect(s.byStatus.values, everyElement(0));
      expect(s.byStatus.length, 4);
    });

    test('erro com Problem Details → Failure com detail e codigo', () async {
      dio.error = problemDetails(401, 'NAO_AUTENTICADO', 'Sessão inválida.');
      final failure = (await repository.getSummary()).fold(
        (l) => l,
        (r) => throw 'devia falhar',
      );
      expect(failure.message, 'Sessão inválida.');
      expect(failure.code, 'NAO_AUTENTICADO');
    });

    test('erro sem Problem Details usa a mensagem padrão', () async {
      dio.error = Exception('rede');
      final failure = (await repository.getSummary()).fold(
        (l) => l,
        (r) => throw 'devia falhar',
      );
      expect(failure.message, 'Falha ao buscar o resumo do dashboard.');
    });
  });

  group('getByLocation', () {
    test(
      'GET /api/v1/dashboard/ativos-por-localidade sem filtro e faz o parse',
      () async {
        dio.response = [locationJson('l1', 'Betim', 5)];
        final result = await repository.getByLocation();

        final call = dio.calls.single;
        expect(call.method, 'GET');
        expect(call.path, '/api/v1/dashboard/ativos-por-localidade');
        expect(call.queryParameters, isNull);
        expect(call.isAuth, isTrue);

        final item = result.getOrElse(() => throw 'falhou').single;
        expect([item.id, item.nome, item.quantidade], ['l1', 'Betim', 5]);
      },
    );

    test('erro → Failure com a mensagem padrão', () async {
      dio.error = Exception('rede');
      final failure = (await repository.getByLocation()).fold(
        (l) => l,
        (r) => throw 'devia falhar',
      );
      expect(failure.message, 'Falha ao buscar ativos por localidade.');
    });
  });
}
