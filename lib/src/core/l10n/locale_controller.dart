import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:iveco_find/l10n/app_localizations.dart';
import 'package:iveco_find/src/core/services/i_local_storage.dart';
import 'package:iveco_find/src/shared/enums/local_storage_keys.dart';

/// Fonte única do idioma do app de gestão.
///
/// A preferência fica só no dispositivo (`LocalStorageKeys.locale`) e não é
/// apagada no logout. Sem preferência válida, segue o idioma do sistema:
/// `es*` abre em espanhol e qualquer outro em PT-BR.
class LocaleController extends ChangeNotifier {
  static const portugueseBrazil = Locale('pt', 'BR');
  static const spanish = Locale('es');

  /// Idiomas suportados, na ordem em que aparecem em Configurações.
  static const supportedLocales = [portugueseBrazil, spanish];

  final LocalStorage storage;

  /// Idioma do sistema; injetável para teste.
  final Locale Function() systemLocale;

  LocaleController({required this.storage, Locale Function()? systemLocale})
    : systemLocale = systemLocale ?? _platformLocale;

  static Locale _platformLocale() => PlatformDispatcher.instance.locale;

  Locale _locale = portugueseBrazil;

  Locale get locale => _locale;

  /// Lê a preferência salva; valor ausente ou inválido cai no padrão do sistema.
  Future<void> load() async {
    String? saved;
    try {
      saved = await storage.getString(LocalStorageKeys.locale.name());
    } catch (_) {
      saved = null;
    }
    _apply(fromTag(saved) ?? defaultFor(systemLocale()));
    notifyListeners();
  }

  /// Troca o idioma na hora e grava a escolha. Se a gravação falhar, a UI
  /// troca mesmo assim (só a persistência é perdida).
  Future<void> setLocale(Locale value) async {
    final resolved = _supported(value);
    if (resolved == null) return;
    _apply(resolved);
    notifyListeners();
    try {
      await storage.setString(LocalStorageKeys.locale.name(), toTag(resolved));
    } catch (_) {
      // A troca já foi aplicada; só a persistência foi perdida.
    }
  }

  void _apply(Locale value) {
    _locale = value;
    L10n.locale = value;
  }

  /// `es*` → espanhol; qualquer outro → PT-BR.
  static Locale defaultFor(Locale system) =>
      system.languageCode == 'es' ? spanish : portugueseBrazil;

  /// Valor gravado no storage (`pt_BR`, `es`).
  static String toTag(Locale value) => value.toString();

  /// Converte o valor gravado; `null` quando ausente ou não suportado.
  static Locale? fromTag(String? tag) {
    if (tag == null) return null;
    for (final item in supportedLocales) {
      if (toTag(item) == tag) return item;
    }
    return null;
  }

  static Locale? _supported(Locale value) {
    for (final item in supportedLocales) {
      if (item.languageCode == value.languageCode) return item;
    }
    return null;
  }
}

/// Textos traduzidos fora da árvore de widgets (repositórios, controllers,
/// PDF). Widgets usam `AppLocalizations.of(context)!` para reconstruir na troca.
class L10n {
  L10n._();

  /// Idioma atual; mantido pelo [LocaleController].
  static Locale locale = LocaleController.portugueseBrazil;

  static AppLocalizations get current => lookupAppLocalizations(locale);

  /// PT-BR fixo, para telas montadas sem os delegates (página pública do QR).
  static AppLocalizations get portuguese =>
      lookupAppLocalizations(LocaleController.portugueseBrazil);
}
