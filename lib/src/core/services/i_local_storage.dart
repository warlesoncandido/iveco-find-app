import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final _prefs = SharedPreferencesAsync();

  Future<String?> getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<void> remove(String key) => _prefs.remove(key);
}
