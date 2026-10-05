import 'package:shared_preferences/shared_preferences.dart';

class QuranReadingSettings {
  static const _fontSizeKey = 'quran_arabic_font_size';
  static const _fontFamilyKey = 'quran_arabic_font_family';

  /// IndoPak (Scheherazade), Amiri, Naskh-style Amiri duplicate label for user choice
  static const fontOptions = ['IndoPak', 'Amiri', 'Naskh'];

  static Future<double> arabicFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? 26;
  }

  static Future<void> setArabicFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size.clamp(18, 36));
  }

  static Future<String> arabicFontFamily() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_fontFamilyKey);
    if (saved == null || saved.isEmpty || !fontOptions.contains(saved)) {
      return 'IndoPak';
    }
    return saved;
  }

  static Future<void> setArabicFontFamily(String family) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontFamilyKey, family);
  }

  static String resolveFontFamily(String label) {
    switch (label) {
      case 'Amiri':
        return 'AmiriQuran';
      case 'Naskh':
        return 'ArabicNaskh';
      case 'IndoPak':
      default:
        return 'IndoPak';
    }
  }
}
