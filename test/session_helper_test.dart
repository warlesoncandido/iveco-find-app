import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:iveco_find/src/core/services/i_local_storage.dart';
import 'package:iveco_find/src/shared/enums/permission.dart';
import 'package:iveco_find/src/shared/repositories/location_repository.dart';
import 'package:iveco_find/src/shared/repositories/section_repository.dart';
import 'package:iveco_find/src/shared/repositories/supplier_repository.dart';
import 'package:iveco_find/src/shared/repositories/types_repository.dart';
import 'package:iveco_find/src/shared/utils/helpers/session_helper.dart';

import 'user/fakes.dart';

void main() {
  late FakeLocalStorage storage;
  late FakeClientDio dio;

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

  setUp(() {
    storage = FakeLocalStorage();
    dio = FakeClientDio()
      ..response = {'itens': [], 'total': 0, 'pagina': 1, 'tamanhoPagina': 25};
    GetIt.instance.registerSingleton<LocalStorage>(storage);
  });

  tearDown(() => GetIt.instance.reset());

  Future<List<String>> listPaths() async {
    await TypesRepository(dio: dio).getTypes(page: 1);
    await SupplierRepository(dio: dio).getSuppliers(page: 1);
    await LocationRepository(dio: dio).getAllLocations(page: 1);
    await SectionRepository(
      dio: dio,
    ).getAllSectionByLocation(locationId: 'l1', page: 1);
    return dio.calls.map((c) => c.path).toList();
  }

  test('ADMINISTRADOR lista cadastros com incluirInativos=true', () async {
    login('ADMINISTRADOR');
    expect(await SessionHelper.can(Permission.cadastrosGerir), isTrue);
    final paths = await listPaths();
    expect(paths, hasLength(4));
    expect(paths.every((p) => p.contains('incluirInativos=true')), isTrue);
  });

  for (final perfil in ['GESTOR', 'OPERACIONAL', 'CONSULTA']) {
    test('$perfil lista cadastros sem incluirInativos (evita 403)', () async {
      login(perfil);
      expect(await SessionHelper.can(Permission.cadastrosGerir), isFalse);
      final paths = await listPaths();
      expect(paths, hasLength(4));
      expect(paths.any((p) => p.contains('incluirInativos')), isFalse);
    });
  }

  test('sem login salvo não pede inativos', () async {
    expect(await SessionHelper.includeInactiveQuery(), isEmpty);
  });
}
