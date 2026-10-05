import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranLastReadService {
  static const _surahNumKey = 'quran_last_read_surah_number';
  static const _surahNameKey = 'quran_last_read_surah_name';
  static const _ayahKey = 'quran_last_read_ayah';
  static const _tsKey = 'quran_last_read_timestamp';

  static final ValueNotifier<int> revision = ValueNotifier(0);

  static Future<void> save({
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_surahNumKey, surahNumber);
    await prefs.setString(_surahNameKey, surahName);
    await prefs.setInt(_ayahKey, ayahNumber);
    await prefs.setInt(_tsKey, DateTime.now().millisecondsSinceEpoch);
    revision.value++;
  }

  static Future<Map<String, dynamic>?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final num = prefs.getInt(_surahNumKey);
    final name = prefs.getString(_surahNameKey);
    final ayah = prefs.getInt(_ayahKey);
    final ts = prefs.getInt(_tsKey);
    if (num == null || name == null || ayah == null) return null;
    return {
      'surahNumber': num,
      'surahName': name,
      'ayah': ayah,
      'timestamp': ts,
    };
  }
}
