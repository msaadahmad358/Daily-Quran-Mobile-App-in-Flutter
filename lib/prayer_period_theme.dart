/// Which header background to show based on current time vs today's prayer times.
enum PrayerPeriod { fajr, sunrise, dhuhr, asr, night }

class PrayerPeriodTheme {
  PrayerPeriodTheme._();

  static const assetPaths = {
    PrayerPeriod.fajr: 'assets/images/prayer/prayer_bg_fajr.jpg',
    PrayerPeriod.sunrise: 'assets/images/prayer/prayer_bg_sunrise.jpg',
    PrayerPeriod.dhuhr: 'assets/images/prayer/prayer_bg_dhuhr.jpg',
    PrayerPeriod.asr: 'assets/images/prayer/prayer_bg_asr.jpg',
    PrayerPeriod.night: 'assets/images/prayer/prayer_bg_night.jpg',
  };

  static PrayerPeriod periodForNow(
    Map<String, dynamic> timings,
    DateTime now,
  ) {
    final fajr = _parseTime(timings['Fajr'], now);
    final sunrise = _parseTime(timings['Sunrise'], now);
    final dhuhr = _parseTime(timings['Dhuhr'], now);
    final asr = _parseTime(timings['Asr'], now);
    final maghrib = _parseTime(timings['Maghrib'], now);

    if (fajr == null || dhuhr == null) return PrayerPeriod.dhuhr;

    if (now.isBefore(fajr)) return PrayerPeriod.night;
    if (sunrise != null && now.isBefore(sunrise)) return PrayerPeriod.fajr;
    if (now.isBefore(dhuhr)) return PrayerPeriod.sunrise;
    if (asr != null && now.isBefore(asr)) return PrayerPeriod.dhuhr;
    if (maghrib != null && now.isBefore(maghrib)) return PrayerPeriod.asr;
    return PrayerPeriod.night;
  }

  static DateTime? _parseTime(String? raw, DateTime ref) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final parts = raw.split(':');
      if (parts.length < 2) return null;
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1].split(' ')[0]);
      return DateTime(ref.year, ref.month, ref.day, h, m);
    } catch (_) {
      return null;
    }
  }
}
