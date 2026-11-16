import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iveco_find/src/core/l10n/locale_controller.dart';
import 'package:iveco_find/src/modules/home/controllers/home_controller.dart';

import '../user/fakes.dart';

/// Storage que falha na leitura e/ou na gravação.
class FailingLocalStorage extends FakeLocalStorage {
  FailingLocalStorage({this.failRead = false, this.failWrite = false});

  final bool failRead;
  final bool failWrite;

  @override
  Future<String?> getString(String key) async {
    if (failRead) throw Exception('storage indisponível');
    return super.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    if (failWrite) throw Exception('storage indisponível');
    return super.setString(key, value);
  }
}

void main() {
  late FakeLocalStorage storage;

  LocaleController build(Locale system, {FakeLocalStorage? custom}) =>
      LocaleController(storage: custom ?? storage, systemLocale: () => system);

  setUp(() {
    storage = FakeLocalStorage();
    L10n.locale = LocaleController.portugueseBrazil;
  });

  group('sem preferência salva segue o dispositivo', () {
    for (final system in const [
      Locale('es'),
      Locale('es', 'AR'),
      Locale('es', 'ES'),
    ]) {
      test('$system → espanhol', () async {
        final controller = build(system);
        await controller.load();
        expect(controller.locale, LocaleController.spanish);
        expect(L10n.current.drawerSettings, 'Configuración');
      });
    }

    for (final system in const [
      Locale('en', 'US'),
      Locale('pt', 'BR'),
      Locale('pt', 'PT'),
      Locale('fr'),
    ]) {
      test('$system → PT-BR', () async {
        final controller = build(system);
        await controller.load();
        expect(controller.locale, LocaleController.portugueseBrazil);
        expect(L10n.current.drawerSettings, 'Configurações');
      });
    }

    test('não grava nada só por carregar', () async {
      await build(const Locale('es')).load();
      expect(storage.values.containsKey('locale'), isFalse);
    });
  });

  group('preferência salva', () {
    test(
      'es salvo abre em espanhol mesmo com o dispositivo em inglês',
      () async {
        storage.values['locale'] = 'es';
        final controller = build(const Locale('en', 'US'));
        await controller.load();
        expect(controller.locale, LocaleController.spanish);
      },
    );

    test(
      'pt_BR salvo abre em PT-BR mesmo com o dispositivo em espanhol',
      () async {
        storage.values['locale'] = 'pt_BR';
        final controller = build(const Locale('es'));
        await controller.load();
        expect(controller.locale, LocaleController.portugueseBrazil);
      },
    );

    for (final invalid in ['fr', 'lixo', '', 'pt', 'ES']) {
      test('valor inválido "$invalid" cai no padrão do dispositivo', () async {
        storage.values['locale'] = invalid;
        final es = build(const Locale('es', 'MX'));
        await es.load();
        expect(es.locale, LocaleController.spanish);

        final pt = build(const Locale('en'));
        await pt.load();
        expect(pt.locale, LocaleController.portugueseBrazil);
      });
    }

    test('falha ao ler o storage cai no padrão do dispositivo', () async {
      final controller = build(
        const Locale('es'),
        custom: FailingLocalStorage(failRead: true),
      );
      await controller.load();
      expect(controller.locale, LocaleController.spanish);
    });
  });

  group('troca de idioma', () {
    test('aplica na hora, notifica e grava', () async {
      final controller = build(const Locale('pt', 'BR'));
      await controller.load();
      var notified = 0;
      controller.addListener(() => notified++);

      await controller.setLocale(LocaleController.spanish);

      expect(controller.locale, LocaleController.spanish);
      expect(notified, 1);
      expect(storage.values['locale'], 'es');
      expect(L10n.current.typesFetchError, 'Error al buscar los tipos.');

      // Ao reabrir o app, continua em espanhol.
      final reopened = build(const Locale('pt', 'BR'));
      await reopened.load();
      expect(reopened.locale, LocaleController.spanish);

      await controller.setLocale(LocaleController.portugueseBrazil);
      expect(storage.values['locale'], 'pt_BR');
      expect(L10n.current.typesFetchError, 'Falha ao buscar tipos.');
    });

    test('falha na gravação: a UI troca mesmo assim', () async {
      final controller = build(
        const Locale('pt', 'BR'),
        custom: FailingLocalStorage(failWrite: true),
      );
      await controller.load();
      await controller.setLocale(LocaleController.spanish);
      expect(controller.locale, LocaleController.spanish);
    });

    test('idioma não suportado é ignorado', () async {
      final controller = build(const Locale('pt', 'BR'));
      await controller.load();
      await controller.setLocale(const Locale('fr'));
      expect(controller.locale, LocaleController.portugueseBrazil);
      expect(storage.values.containsKey('locale'), isFalse);
    });
  });

  test('logout mantém o idioma escolhido', () async {
    storage.values['auth'] = '{}';
    final controller = build(const Locale('pt', 'BR'));
    await controller.setLocale(LocaleController.spanish);

    final home = HomeController(
      authRepository: FakeAuthRepository(),
      storage: storage,
    );
    await home.logout(onSuccess: () {});

    expect(storage.values.containsKey('auth'), isFalse);
    expect(storage.values['locale'], 'es');
    final reopened = build(const Locale('pt', 'BR'));
    await reopened.load();
    expect(reopened.locale, LocaleController.spanish);
  });
}
