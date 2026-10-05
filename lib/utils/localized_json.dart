/// Picks localized strings from JSON maps with `en` / `fr` / `ar` keys.
class LocalizedJson {
  LocalizedJson._();

  static String langCode(String appLanguage) {
    switch (appLanguage) {
      case 'French':
        return 'fr';
      case 'Arabic':
        return 'ar';
      default:
        return 'en';
    }
  }

  static String pick(Map? map, String appLanguage) {
    if (map == null || map.isEmpty) return '';
    final code = langCode(appLanguage);
    final value = map[code] ?? map['en'] ?? map.values.first;
    return value?.toString() ?? '';
  }

  static String pickOr(
    Map? map,
    String appLanguage, {
    String fallback = '',
  }) {
    final s = pick(map, appLanguage);
    return s.isEmpty ? fallback : s;
  }

  /// Dua body: English or French only (settings language), not both.
  static String duaMeaning(Map<String, dynamic> dua, String appLanguage) {
    if (appLanguage == 'French') {
      return dua['french']?.toString() ?? dua['english']?.toString() ?? '';
    }
    return dua['english']?.toString() ?? dua['french']?.toString() ?? '';
  }

  /// Ayah / hadith meaning line — English or French only.
  static String meaningField(Map<String, dynamic> item, String appLanguage) {
    if (appLanguage == 'French') {
      return item['french']?.toString() ?? item['english']?.toString() ?? '';
    }
    return item['english']?.toString() ?? item['french']?.toString() ?? '';
  }
}
