import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:iveco_find/src/core/l10n/locale_controller.dart';
import 'package:iveco_find/src/core/l10n/localized_app.dart';
import 'package:iveco_find/src/modules/home/controllers/home_controller.dart';
import 'package:iveco_find/src/modules/home/pages/settings/pages/settings_page.dart';
import 'package:iveco_find/src/shared/components/i_drawer.dart';

import '../user/fakes.dart';

/// O mesmo [LocalizedApp] do `MyApp`, com uma rota só.
Widget _app(LocaleController localeController, HomeController home) {
  return LocalizedApp(
    controller: localeController,
    routerConfig: GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Row(
              children: [
                SizedBox(width: 300, child: IDrawerComponent(controller: home)),
                Expanded(child: SettingsPage(controller: localeController)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

void main() {
  late FakeLocalStorage storage;
  late HomeController home;

  setUp(() {
    storage = FakeLocalStorage()
      ..values['auth'] = json.encode({
        'token': 't',
        'trocaSenhaObrigatoria': false,
        'usuario': {
          'id': 'u1',
          'nome': 'Maria',
          'email': 'maria@iveco.com',
          'perfil': 'CONSULTA',
        },
      });
    home = HomeController(
      authRepository: FakeAuthRepository(),
      storage: storage,
    );
    L10n.locale = LocaleController.portugueseBrazil;
  });

  Future<LocaleController> pump(WidgetTester tester, Locale system) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = LocaleController(
      storage: storage,
      systemLocale: () => system,
    );
    await controller.load();
    await tester.pumpWidget(_app(controller, home));
    await home.loadPerfil();
    await tester.pumpAndSettle();
    return controller;
  }

  testWidgets('mostra os idiomas na própria língua com o atual marcado', (
    tester,
  ) async {
    await pump(tester, const Locale('pt', 'BR'));
    expect(find.text('Idioma'), findsOneWidget);
    expect(find.text('Português (Brasil)'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);

    final selected = tester.widget<RadioGroup<Locale>>(
      find.byType(RadioGroup<Locale>),
    );
    expect(selected.groupValue, LocaleController.portugueseBrazil);
  });

  testWidgets('escolher Español troca a UI na hora e grava a preferência', (
    tester,
  ) async {
    final controller = await pump(tester, const Locale('pt', 'BR'));
    expect(find.text('Configurações'), findsNWidgets(2)); // drawer + título
    expect(find.text('Sair'), findsOneWidget);

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(controller.locale, LocaleController.spanish);
    expect(storage.values['locale'], 'es');
    expect(find.text('Configuración'), findsNWidgets(2));
    expect(find.text('Salir'), findsOneWidget);
    expect(find.text('Activos'), findsOneWidget);
    expect(find.text('Gestión de activos'), findsOneWidget);
    expect(find.text('Configurações'), findsNothing);
    // Widgets do Material acompanham o idioma.
    final material = MaterialLocalizations.of(
      tester.element(find.byType(SettingsPage)),
    );
    expect(material.cancelButtonLabel.toLowerCase(), 'cancelar');
    expect(material.okButtonLabel, 'ACEPTAR');

    // Ao reabrir o app (novo controller), continua em espanhol.
    final reopened = LocaleController(
      storage: storage,
      systemLocale: () => const Locale('pt', 'BR'),
    );
    await reopened.load();
    expect(reopened.locale, LocaleController.spanish);
  });

  testWidgets('dispositivo em espanhol abre em espanhol', (tester) async {
    await pump(tester, const Locale('es', 'AR'));
    expect(find.text('Configuración'), findsNWidgets(2));
    final selected = tester.widget<RadioGroup<Locale>>(
      find.byType(RadioGroup<Locale>),
    );
    expect(selected.groupValue, LocaleController.spanish);
  });

  testWidgets('voltar para Português (Brasil) traduz de volta', (tester) async {
    storage.values['locale'] = 'es';
    final controller = await pump(tester, const Locale('en'));
    expect(find.text('Salir'), findsOneWidget);

    await tester.tap(find.text('Português (Brasil)'));
    await tester.pumpAndSettle();

    expect(controller.locale, LocaleController.portugueseBrazil);
    expect(storage.values['locale'], 'pt_BR');
    expect(find.text('Sair'), findsOneWidget);
  });
}
