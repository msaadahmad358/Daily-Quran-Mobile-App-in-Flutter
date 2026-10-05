import 'package:qrn_app/utils/localized_json.dart';

class JsonSectionLabels {
  JsonSectionLabels._();

  static const _en = {
    'prayerTimes': 'Prayer times',
    'conditions': 'Conditions',
    'wudu': 'Ablution (Wudu)',
    'pillars': 'Pillars',
    'steps': 'Steps',
    'rakahPattern': 'Rakah pattern',
    'rawatib': 'Sunnah prayers (Rawatib)',
    'nullifiers': 'Nullifiers of prayer',
    'sujudSahw': 'Prostration of forgetfulness',
    'khushu': 'Khushu (focus)',
    'quranAyahs': 'Quranic verses',
    'hadiths': 'Hadiths',
    'types': 'Types',
    'days': 'Days',
    'sacrifice': 'Sacrifice',
    'women': 'Guidance for women',
    'topics': 'Topics',
    'counts': 'Overview',
  };

  static const _fr = {
    'prayerTimes': 'Heures de prière',
    'conditions': 'Conditions',
    'wudu': 'Ablutions (Wudu)',
    'pillars': 'Piliers',
    'steps': 'Étapes',
    'rakahPattern': 'Schéma des rakahs',
    'rawatib': 'Prières sura (Rawatib)',
    'nullifiers': 'Annulateurs de la prière',
    'sujudSahw': 'Prosternation de l\'oubli',
    'khushu': 'Khushu (concentration)',
    'quranAyahs': 'Versets coraniques',
    'hadiths': 'Hadiths',
    'types': 'Types',
    'days': 'Jours',
    'sacrifice': 'Sacrifice',
    'women': 'Conseils pour les femmes',
    'topics': 'Thèmes',
    'counts': 'Aperçu',
  };

  static String label(String key, String appLanguage) {
    final code = LocalizedJson.langCode(appLanguage);
    final map = code == 'fr' ? _fr : _en;
    return map[key] ??
        key
            .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}')
            .replaceFirstMapped(RegExp(r'^.'), (m) => m.group(0)!.toUpperCase())
            .trim();
  }
}
