import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TasbeehDhikr {
  final String id;
  final String arabic;
  final int target;
  final bool isCustom;

  const TasbeehDhikr({
    required this.id,
    required this.arabic,
    required this.target,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'arabic': arabic,
        'target': target,
        'isCustom': isCustom,
      };

  factory TasbeehDhikr.fromJson(Map<String, dynamic> json) => TasbeehDhikr(
        id: json['id'] as String,
        arabic: json['arabic'] as String,
        target: (json['target'] as num).toInt(),
        isCustom: json['isCustom'] as bool? ?? true,
      );

  TasbeehDhikr copyWith({String? arabic, int? target}) => TasbeehDhikr(
        id: id,
        arabic: arabic ?? this.arabic,
        target: target ?? this.target,
        isCustom: isCustom,
      );
}

class TasbeehStorageService {
  static const _customKey = 'tasbeeh_custom_dhikr_v1';
  static const _countsKey = 'tasbeeh_counts_v1';
  static const _selectedKey = 'tasbeeh_selected_id_v1';

  static const List<TasbeehDhikr> defaults = [
    TasbeehDhikr(
      id: 'subhanallah',
      arabic: 'سُبْحَانَ اللَّهِ',
      target: 33,
    ),
    TasbeehDhikr(
      id: 'alhamdulillah',
      arabic: 'الْحَمْدُ لِلَّهِ',
      target: 33,
    ),
    TasbeehDhikr(
      id: 'allahu_akbar',
      arabic: 'اللَّهُ أَكْبَرُ',
      target: 34,
    ),
    TasbeehDhikr(
      id: 'la_ilaha',
      arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      target: 100,
    ),
    TasbeehDhikr(
      id: 'astaghfirullah',
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      target: 100,
    ),
    TasbeehDhikr(
      id: 'salawat',
      arabic: 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ',
      target: 100,
    ),
  ];

  static Future<List<TasbeehDhikr>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_customKey);
    final custom = <TasbeehDhikr>[];
    if (raw != null) {
      try {
        final list = json.decode(raw) as List<dynamic>;
        for (final e in list) {
          custom.add(TasbeehDhikr.fromJson(e as Map<String, dynamic>));
        }
      } catch (_) {}
    }
    return [...defaults, ...custom];
  }

  static Future<void> saveCustomList(List<TasbeehDhikr> custom) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(custom.map((e) => e.toJson()).toList());
    await prefs.setString(_customKey, encoded);
  }

  static Future<String?> loadSelectedId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedKey);
  }

  static Future<void> saveSelectedId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedKey, id);
  }

  static Future<Map<String, int>> loadCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_countsKey);
    if (raw == null) return {};
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveCount(String id, int count) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await loadCounts();
    all[id] = count;
    await prefs.setString(_countsKey, json.encode(all));
  }

  static Future<void> clearCount(String id) async {
    final all = await loadCounts();
    all.remove(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_countsKey, json.encode(all));
  }
}
