import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:iveco_find/src/core/services/i_local_storage.dart';
import 'package:iveco_find/src/modules/home/pages/location/controllers/location_controller.dart';
import 'package:iveco_find/src/modules/home/pages/supplier/controllers/supplier_controller.dart';
import 'package:iveco_find/src/modules/home/pages/types/controllers/types_controller.dart';
import 'package:iveco_find/src/shared/models/pagination_model.dart';
import 'package:iveco_find/src/shared/repositories/location_repository.dart';
import 'package:iveco_find/src/shared/repositories/supplier_repository.dart';
import 'package:iveco_find/src/shared/repositories/types_repository.dart';
import 'package:iveco_find/src/shared/utils/behaviour_page.dart';
import 'package:iveco_find/src/shared/utils/failure.dart';

import '../user/fakes.dart';

/// Chamada de listagem gravada pelos repositórios falsos.
class ListCall {
  final int page;
  final String query;
  ListCall(this.page, this.query);
}

/// Base dos repositórios falsos: grava (page, query) e devolve `items`.
mixin FakeList {
  final calls = <ListCall>[];
  Failure? failure;
  Completer<void>? gate;
  List<Object> items = const [];

  Future<Either<Failure, PaginationModel>> list(int page, String query) async {
    calls.add(ListCall(page, query));
    final g = gate;
    final snapshot = items;
    if (g != null) await g.future;
    if (failure != null) return Left(failure!);
    return Right(
      PaginationModel(
        total: snapshot.length,
        page: page,
        maxPerPage: 25,
        items: snapshot,
      ),
    );
  }
}

class FakeTypesRepository with FakeList implements TypesRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Either<Failure, PaginationModel>> getTypes({
    required int page,
    String query = '',
  }) => list(page, query);
}

class FakeSupplierRepository with FakeList implements SupplierRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Either<Failure, PaginationModel>> getSuppliers({
    required int page,
    String query = '',
  }) => list(page, query);
}

class FakeLocationRepository with FakeList implements LocationRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Either<Failure, PaginationModel>> getAllLocations({
    required int page,
    String query = '',
  }) => list(page, query);
}

/// Adapta os três controllers a uma interface comum para os testes.
class Subject {
  final String name;
  final FakeList repo;
  final dynamic controller;
  final Future<void> Function() load;
  final void Function(String) search;
  final void Function(int) setPage;
  final List<dynamic>? Function() items;
  Subject(
    this.name,
    this.repo,
    this.controller,
    this.load,
    this.search,
    this.setPage,
    this.items,
  );
}

List<Subject Function()> subjects = [
  () {
    final r = FakeTypesRepository();
    final c = TypesController(typesRepository: r);
    return Subject(
      'Tipos',
      r,
      c,
      c.loadTypes,
      c.search,
      c.setCurrentPage,
      () => c.pagination?.items,
    );
  },
  () {
    final r = FakeSupplierRepository();
    final c = SupplierController(repository: r);
    return Subject(
      'Fornecedores',
      r,
      c,
      c.loadSuppliers,
      c.search,
      c.setCurrentPage,
      () => c.pagination?.items,
    );
  },
  () {
    final r = FakeLocationRepository();
    final c = LocationController(repository: r);
    return Subject(
      'Localidades',
      r,
      c,
      c.loadLocations,
      c.search,
      c.setCurrentPage,
      () => c.pagination?.items,
    );
  },
];

void main() {
  group('repositórios enviam q', () {
    late FakeLocalStorage storage;
    late FakeClientDio dio;

    setUp(() {
      storage = FakeLocalStorage();
      dio = FakeClientDio()
        ..response = {
          'itens': [],
          'total': 0,
          'pagina': 1,
          'tamanhoPagina': 25,
        };
      GetIt.instance.registerSingleton<LocalStorage>(storage);
    });

    tearDown(() => GetIt.instance.reset());

    void login(String perfil) {
      storage.values['auth'] = json.encode({
        'token': 't',
        'trocaSenhaObrigatoria': false,
        'usuario': {
          'id': 'u1',
          'nome': 'Maria',
          'email': 'maria@iveco.com',
          'perfil': perfil,
        },
      });
    }

    final calls = <String, Future<void> Function(FakeClientDio, int, String)>{
      '/api/v1/tipos-ativo': (d, p, q) =>
          TypesRepository(dio: d).getTypes(page: p, query: q),
      '/api/v1/fornecedores': (d, p, q) =>
          SupplierRepository(dio: d).getSuppliers(page: p, query: q),
      '/api/v1/localidades': (d, p, q) =>
          LocationRepository(dio: d).getAllLocations(page: p, query: q),
    };

    calls.forEach((path, call) {
      test('$path: q sem espaços, página pedida e incluirInativos', () async {
        login('ADMINISTRADOR');
        await call(dio, 3, ' 12.345.678/0001 ');
        final c = dio.calls.single;
        expect(c.path, path);
        expect(c.isAuth, isTrue);
        expect(c.queryParameters, {
          'pagina': 3,
          'tamanhoPagina': 25,
          'ordem': 'asc',
          'q': '12.345.678/0001',
          'incluirInativos': 'true',
        });
      });

      test('$path: busca em branco não envia q', () async {
        login('CONSULTA');
        await call(dio, 1, '   ');
        expect(dio.calls.single.queryParameters, {
          'pagina': 1,
          'tamanhoPagina': 25,
          'ordem': 'asc',
        });
      });
    });
  });

  for (final make in subjects) {
    final name = make().name;
    group('controller de $name', () {
      late Subject s;
      setUp(() => s = make());

      test('carga inicial: página 1 sem q', () async {
        await s.load();
        final call = s.repo.calls.single;
        expect(call.page, 1);
        expect(call.query, '');
        expect(s.controller.behaviourPage, Behaviour.success);
      });

      test('setCurrentPage recarrega com a nova página e o termo', () async {
        s.controller.query = 'acme';
        s.setPage(2);
        await Future<void>.delayed(Duration.zero);
        expect(s.repo.calls.single.page, 2);
        expect(s.repo.calls.single.query, 'acme');
      });

      // testWidgets roda em FakeAsync: tester.pump avança o relógio do Timer.
      testWidgets('search: debounce de 400 ms e volta à página 1', (
        tester,
      ) async {
        s.controller.currentPage = 4;
        s.search('fu');
        await tester.pump(const Duration(milliseconds: 200));
        s.search('fur');
        await tester.pump(const Duration(milliseconds: 399));
        expect(s.repo.calls, isEmpty);

        await tester.pump(const Duration(milliseconds: 1));
        final call = s.repo.calls.single;
        expect(call.query, 'fur');
        expect(call.page, 1);
        expect(s.controller.currentPage, 1);
        expect(s.controller.query, 'fur');
      });

      test('erro → Behaviour.error', () async {
        s.repo.failure = Failure(message: 'x');
        await s.load();
        expect(s.controller.behaviourPage, Behaviour.error);
      });

      test('respostas fora de ordem: vale a carga mais recente', () async {
        final slow = Completer<void>();
        s.repo.gate = slow;
        s.repo.items = ['antigo'];
        final first = s.load(); // fica pendente
        s.repo.gate = null;
        s.repo.items = ['novo'];
        await s.load(); // responde antes
        slow.complete();
        await first;
        expect(s.items(), ['novo']);
        expect(s.controller.behaviourPage, Behaviour.success);
      });
    });
  }
}
