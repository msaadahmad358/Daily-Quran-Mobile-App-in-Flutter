/// QUL Surah Name V4 — same font as tarteelaps (`surah-name-v4.ttf`).
class SurahNameV4Font {
  SurahNameV4Font._();

  static const family = 'SurahNameV4';

  /// PUA code for surah *n* (`U+E000 + n`).
  static String glyph(int surahId) =>
      String.fromCharCode(0xE000 + surahId.clamp(1, 114));
}
