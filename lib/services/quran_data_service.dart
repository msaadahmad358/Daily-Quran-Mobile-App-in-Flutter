import 'dart:convert';

import 'package:flutter/services.dart';

/// Offline Quran JSON — load once at app start.
class QuranDataService {
  QuranDataService._();
  static final QuranDataService instance = QuranDataService._();

  Map<String, dynamic> _surahs = {};
  List<String> _keys = [];
  bool _ready = false;
  Future<void>? _loading;

  bool get isReady => _ready;
  Map<String, dynamic> get surahs => _surahs;
  List<String> get surahKeys => List.unmodifiable(_keys);

  Future<void> load() {
    _loading ??= _loadInternal();
    return _loading!;
  }

  Future<void> _loadInternal() async {
    if (_ready) return;
    final raw = await rootBundle.loadString('assets/quran_data.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    if (data.containsKey('surahs')) {
      _surahs = Map<String, dynamic>.from(data['surahs'] as Map);
    } else {
      _surahs = data;
    }
    _keys = _surahs.keys.toList();
    _ready = true;
  }

  String? keyForSurahNumber(int number) {
    for (final key in _keys) {
      final s = _surahs[key] as Map<String, dynamic>;
      if (s['surah_number'] == number) return key;
    }
    return null;
  }

  Map<String, dynamic>? surahByNumber(int number) {
    final key = keyForSurahNumber(number);
    if (key == null) return null;
    return _surahs[key] as Map<String, dynamic>;
  }
}
