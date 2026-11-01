import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/modules/home/controllers/home_controller.dart';

import 'fakes.dart';

void main() {
  late FakeLocalStorage storage;
  late HomeController controller;

  void saveAuth(String perfil, {bool withAtivo = true}) {
    storage.values['auth'] = json.encode({
      'token': 't',
      'trocaSenhaObrigatoria': false,
      'usuario': {
        'id': 'u1',
        'nome': 'Maria',
        'email': 'maria@iveco.com',
        'perfil': perfil,
        if (withAtivo) 'ativo': true,
      },
    });
  }

  setUp(() {
    storage = FakeLocalStorage();
    controller = HomeController(
      authRepository: FakeAuthRepository(),
      storage: storage,
    );
  });

  test('ADMINISTRADOR → isAdmin', () async {
    saveAuth('ADMINISTRADOR');
    await controller.loadPerfil();
    expect(controller.perfil, 'ADMINISTRADOR');
    expect(controller.isAdmin, isTrue);
  });

  test(
    'auth antigo (sem ativo) de ADMINISTRADOR continua funcionando',
    () async {
      saveAuth('ADMINISTRADOR', withAtivo: false);
      await controller.loadPerfil();
      expect(controller.isAdmin, isTrue);
    },
  );

  for (final perfil in ['GESTOR', 'OPERACIONAL', 'CONSULTA']) {
    test('$perfil → não é admin (sem item Usuários)', () async {
      saveAuth(perfil);
      await controller.loadPerfil();
      expect(controller.isAdmin, isFalse);
    });
  }

  test('sem auth salvo → não é admin', () async {
    await controller.loadPerfil();
    expect(controller.perfil, isNull);
    expect(controller.isAdmin, isFalse);
  });

  test('troca de login: admin → gestor deixa de ser admin', () async {
    saveAuth('ADMINISTRADOR');
    await controller.loadPerfil();
    saveAuth('GESTOR');
    await controller.loadPerfil();
    expect(controller.isAdmin, isFalse);
  });

  test('logout limpa o perfil e o auth', () async {
    saveAuth('ADMINISTRADOR');
    await controller.loadPerfil();
    var done = false;
    await controller.logout(onSuccess: () => done = true);
    expect(done, isTrue);
    expect(controller.isAdmin, isFalse);
    expect(storage.values.containsKey('auth'), isFalse);
  });

  // setSelectedIndex anima o PageController: precisa de um PageView montado.
  testWidgets('logout volta o selectedIndex para 0 e notifica', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PageView(
          controller: controller.pageController,
          children: List.generate(7, (i) => Text('page $i')),
        ),
      ),
    );
    saveAuth('ADMINISTRADOR');
    await controller.loadPerfil();
    controller.setSelectedIndex(6);
    await tester.pumpAndSettle();
    expect(controller.selectedIndex, 6);

    var notified = 0;
    controller.addListener(() => notified++);
    await controller.logout(onSuccess: () {});
    expect(controller.selectedIndex, 0);
    expect(controller.isAdmin, isFalse);
    expect(notified, greaterThan(0));
  });
}
