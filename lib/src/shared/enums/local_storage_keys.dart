enum LocalStorageKeys {
  auth;

  String name() {
    switch (this) {
      case LocalStorageKeys.auth:
        return 'auth';
    }
  }
}
