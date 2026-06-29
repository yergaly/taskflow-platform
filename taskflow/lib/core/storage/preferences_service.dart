import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService(this._prefs);

  static const _themeModeKey = 'theme_mode';

  final SharedPreferences _prefs;

  static Future<PreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  String? get themeMode => _prefs.getString(_themeModeKey);

  Future<void> setThemeMode(String value) async {
    await _prefs.setString(_themeModeKey, value);
  }
}
