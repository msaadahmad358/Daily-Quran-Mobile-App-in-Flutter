import 'dart:convert';

import 'package:flutter/services.dart';

class SurahIndexMeta {
  SurahIndexMeta({
    required this.id,
    required this.name,
    required this.ayahs,
    required this.revelation,
  });

  final int id;
  final String name;
  final int ayahs;
  final String revelation;

  String get revealedIn =>
      revelation.toLowerCase().contains('med') ? 'Madinah' : 'Makkah';

  static Map<int, SurahIndexMeta>? _cache;

  static Future<SurahIndexMeta?> forId(int id) async {
    await _ensureLoaded();
    return _cache![id];
  }

  static Future<void> _ensureLoaded() async {
    if (_cache != null) return;
    final raw =
        await rootBundle.loadString('assets/data/quran-index.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final list = data['surahs'] as List;
    final map = <int, SurahIndexMeta>{};
    for (final item in list) {
      final j = Map<String, dynamic>.from(item as Map);
      final meta = SurahIndexMeta(
        id: (j['id'] as num).toInt(),
        name: j['name']?.toString() ?? '',
        ayahs: (j['ayahs'] as num?)?.toInt() ?? 0,
        revelation: j['revelation']?.toString() ?? 'Meccan',
      );
      map[meta.id] = meta;
    }
    _cache = map;
  }
}
