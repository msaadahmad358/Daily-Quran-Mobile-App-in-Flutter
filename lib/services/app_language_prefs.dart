import 'package:shared_preferences/shared_preferences.dart';

class AppLanguagePrefs {
  AppLanguagePrefs._();

  static const _key = 'app_language';
  static const defaultLanguage = 'French';

  static Future<String> get() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? defaultLanguage;
  }

  static Future<void> set(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, language);
  }
}
