import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:iveco_find/l10n/app_localizations.dart';
import 'package:iveco_find/src/core/l10n/locale_controller.dart';

/// `MaterialApp.router` que ouve o [LocaleController]: a troca de idioma em
/// Configurações reconstrói o app na hora, inclusive os widgets do Material.
class LocalizedApp extends StatelessWidget {
  final LocaleController controller;
  final RouterConfig<Object> routerConfig;
  final ThemeData? theme;
  final String title;

  const LocalizedApp({
    super.key,
    required this.controller,
    required this.routerConfig,
    this.theme,
    this.title = '',
  });

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => MaterialApp.router(
        title: title,
        debugShowCheckedModeBanner: false,
        locale: controller.locale,
        supportedLocales: LocaleController.supportedLocales,
        localizationsDelegates: localizationsDelegates,
        theme: theme,
        routerConfig: routerConfig,
      ),
    );
  }
}
