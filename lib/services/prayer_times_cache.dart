import 'dart:convert';



import 'package:shared_preferences/shared_preferences.dart';



typedef PrayerTimesCacheData = ({

  Map<String, dynamic> times,

  String location,

  String hijri,

  String timezone,

});



class PrayerTimesCache {

  PrayerTimesCache._();



  static const _timesKey = 'prayer_cache_times_json';

  static const _locationKey = 'prayer_cache_location';

  static const _hijriKey = 'prayer_cache_hijri';

  static const _timezoneKey = 'prayer_cache_timezone';



  static PrayerTimesCacheData? _memory;



  static PrayerTimesCacheData? peek() => _memory;



  static Future<PrayerTimesCacheData?> load() async {

    if (_memory != null) return _memory;

    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_timesKey);

    if (raw == null || raw.isEmpty) return null;

    try {

      final times = Map<String, dynamic>.from(jsonDecode(raw) as Map);

      _memory = (

        times: times,

        location: prefs.getString(_locationKey) ?? '',

        hijri: prefs.getString(_hijriKey) ?? '',

        timezone: prefs.getString(_timezoneKey) ?? 'Europe/Paris',

      );

      return _memory;

    } catch (_) {

      return null;

    }

  }



  static Future<void> save({

    required Map<String, dynamic> times,

    required String location,

    required String hijri,

    required String timezone,

  }) async {

    _memory = (

      times: times,

      location: location,

      hijri: hijri,

      timezone: timezone,

    );

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_timesKey, jsonEncode(times));

    await prefs.setString(_locationKey, location);

    await prefs.setString(_hijriKey, hijri);

    await prefs.setString(_timezoneKey, timezone);

  }

}


