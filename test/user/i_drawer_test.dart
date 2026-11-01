import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/modules/home/controllers/home_controller.dart';
import 'package:iveco_find/src/shared/components/i_drawer.dart';

import 'fakes.dart';

void main() {
  Future<void> pumpDrawer(WidgetTester tester, String? perfil) async {
    final storage = FakeLocalStorage();
    if (perfil != null) {
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
    final controller = HomeController(
      authRepository: FakeAuthRepository(),
      storage: storage,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: IDrawerComponent(controller: controller)),
      ),
    );
    await controller.loadPerfil();
    await tester.pump();
  }

  testWidgets('ADMINISTRADOR vê o item Usuários', (tester) async {
    await pumpDrawer(tester, 'ADMINISTRADOR');
    expect(find.text('Usuários'), findsOneWidget);
    expect(find.text('Localidades'), findsOneWidget);
  });

  for (final perfil in ['GESTOR', 'OPERACIONAL', 'CONSULTA']) {
    testWidgets('$perfil não vê o item Usuários', (tester) async {
      await pumpDrawer(tester, perfil);
      expect(find.text('Usuários'), findsNothing);
      expect(find.text('Localidades'), findsOneWidget);
    });
  }

  testWidgets('sem auth salvo não vê o item Usuários', (tester) async {
    await pumpDrawer(tester, null);
    expect(find.text('Usuários'), findsNothing);
  });
}
