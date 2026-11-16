import 'package:flutter/material.dart';
import 'package:iveco_find/src/core/l10n/locale_controller.dart';
import 'package:iveco_find/src/core/l10n/localized_app.dart';

/// `MaterialApp` com os delegates de localização do app; PT por padrão.
Widget localizedApp({
  required Widget home,
  Locale locale = const Locale('pt'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: LocaleController.supportedLocales,
    localizationsDelegates: LocalizedApp.localizationsDelegates,
    home: home,
  );
}
