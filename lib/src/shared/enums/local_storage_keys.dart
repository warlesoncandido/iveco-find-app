enum LocalStorageKeys {
  auth,

  /// Idioma escolhido em Configurações (`pt_BR` ou `es`). Só local; o logout não apaga.
  locale;

  String name() {
    switch (this) {
      case LocalStorageKeys.auth:
        return 'auth';
      case LocalStorageKeys.locale:
        return 'locale';
    }
  }
}
