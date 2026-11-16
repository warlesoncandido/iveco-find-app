import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/modules/home/controllers/home_controller.dart';
import 'package:iveco_find/src/modules/home/pages/home_page.dart';
import 'package:iveco_find/src/modules/home/pages/settings/pages/settings_page.dart';
import 'package:iveco_find/src/shared/components/i_drawer.dart';

import '../helpers/localized_app.dart';
import 'fakes.dart';

void main() {
  late HomeController controller;

  Future<void> pumpDrawer(
    WidgetTester tester,
    String? perfil, {
    Locale locale = const Locale('pt'),
  }) async {
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
    controller = HomeController(
      authRepository: FakeAuthRepository(),
      storage: storage,
    );
    await tester.pumpWidget(
      localizedApp(
        locale: locale,
        home: Scaffold(
          body: Row(
            children: [
              Expanded(child: IDrawerComponent(controller: controller)),
              // setSelectedIndex anima o PageController: precisa de um PageView.
              Expanded(
                child: PageView(
                  controller: controller.pageController,
                  children: List.generate(8, (i) => Text('page $i')),
                ),
              ),
            ],
          ),
        ),
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

  const leitura = [
    'Dashboard',
    'Ativos',
    'Tipos',
    'Fornecedores',
    'Localidades',
  ];

  for (final perfil in ['ADMINISTRADOR', 'GESTOR', 'OPERACIONAL', 'CONSULTA']) {
    testWidgets('$perfil vê as telas de leitura e Sair; Relatórios some', (
      tester,
    ) async {
      await pumpDrawer(tester, perfil);
      for (final title in leitura) {
        expect(find.text(title), findsOneWidget, reason: title);
      }
      expect(find.text('Sair'), findsOneWidget);
      expect(find.text('Relatorios'), findsNothing);
    });
  }

  testWidgets('sem auth salvo só sobram Configurações e Sair', (tester) async {
    await pumpDrawer(tester, null);
    for (final title in [...leitura, 'Usuários', 'Relatorios']) {
      expect(find.text(title), findsNothing, reason: title);
    }
    expect(find.text('Configurações'), findsOneWidget);
    expect(find.text('Sair'), findsOneWidget);
  });

  for (final perfil in ['ADMINISTRADOR', 'GESTOR', 'OPERACIONAL', 'CONSULTA']) {
    testWidgets('$perfil vê o item Configurações', (tester) async {
      await pumpDrawer(tester, perfil);
      expect(find.text('Configurações'), findsOneWidget);
    });
  }

  testWidgets('em espanhol: Configuración, Salir e títulos traduzidos', (
    tester,
  ) async {
    await pumpDrawer(tester, 'ADMINISTRADOR', locale: const Locale('es'));
    expect(find.text('Gestión de activos'), findsOneWidget);
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('Salir'), findsOneWidget);
    expect(find.text('Activos'), findsOneWidget);
    expect(find.text('Proveedores'), findsOneWidget);
    expect(find.text('Usuarios'), findsOneWidget);
    expect(find.text('Configurações'), findsNothing);
    expect(find.text('Sair'), findsNothing);
  });

  testWidgets('tocar em Configurações abre a página de Configurações', (
    tester,
  ) async {
    await pumpDrawer(tester, 'CONSULTA');
    await tester.tap(find.text('Configurações'));
    await tester.pumpAndSettle();
    expect(controller.selectedIndex, settingsPageIndex);
    expect(find.text('page $settingsPageIndex'), findsOneWidget);
  });

  test('settingsPageIndex aponta para a SettingsPage no PageView da Home', () {
    final pages = HomePage.pages(
      controller = HomeController(
        authRepository: FakeAuthRepository(),
        storage: FakeLocalStorage(),
      ),
    );
    expect(pages[settingsPageIndex], isA<SettingsPage>());
  });
}
