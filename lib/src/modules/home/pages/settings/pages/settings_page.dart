import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:iveco_find/l10n/app_localizations.dart';
import 'package:iveco_find/src/core/l10n/locale_controller.dart';
import 'package:iveco_find/src/core/theme/i_theme.dart';
import 'package:iveco_find/src/core/theme/spaccing.dart';

/// Configurações do app (por enquanto, só o idioma). Visível para todos os perfis.
class SettingsPage extends StatelessWidget {
  /// Opcional (testes); por padrão vem do GetIt.
  final LocaleController? controller;

  const SettingsPage({super.key, this.controller});

  /// Nome de cada idioma na própria língua.
  static String languageName(AppLocalizations l, Locale locale) =>
      switch (locale.languageCode) {
        'es' => l.languageSpanish,
        _ => l.languagePortugueseBrazil,
      };

  @override
  Widget build(BuildContext context) {
    final localeController =
        controller ?? GetIt.instance.get<LocaleController>();
    final l = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: localeController,
      builder: (context, _) {
        return Scaffold(
          body: ListView(
            padding: EdgeInsets.all(md),
            children: [
              Text(l.settingsTitle, style: ITheme.styles.titleBold()),
              SizedBox(height: md),
              Card(
                color: ITheme.colors.branco,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: sm),
                  child: RadioGroup<Locale>(
                    groupValue: localeController.locale,
                    onChanged: (value) {
                      if (value != null) localeController.setLocale(value);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Icon(Icons.language),
                          title: Text(
                            l.settingsLanguageSection,
                            style: ITheme.styles.bodyBold(),
                          ),
                          subtitle: Text(l.settingsLanguageDescription),
                        ),
                        for (final locale in LocaleController.supportedLocales)
                          RadioListTile<Locale>(
                            value: locale,
                            title: Text(languageName(l, locale)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
