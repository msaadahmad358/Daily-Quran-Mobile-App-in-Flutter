import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranPdfLastReadService {
  static const _pageKey = 'quran_pdf_last_read_page';
  static const _labelKey = 'quran_pdf_last_read_label';
  static const _timeKey = 'quran_pdf_last_read_timestamp';

  static final ValueNotifier<int> revision = ValueNotifier(0);

  static Future<void> save(int catalogPage, String label) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pageKey, catalogPage);
    await prefs.setString(_labelKey, label);
    await prefs.setInt(_timeKey, DateTime.now().millisecondsSinceEpoch);
    revision.value++;
  }

  static Future<({int page, String label, int? timestamp})?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final page = prefs.getInt(_pageKey);
    final label = prefs.getString(_labelKey);
    if (page == null || label == null) return null;
    return (
      page: page,
      label: label,
      timestamp: prefs.getInt(_timeKey),
    );
  }
}
