import 'package:http/http.dart' as http;

/// Online ayah recitation URLs (Mishary Alafasy).
class QuranAyahAudio {
  QuranAyahAudio._();

  static const _everyAyahBase = 'https://everyayah.com/data/Alafasy_128kbps';
  static const _cdnBase =
      'https://cdn.islamic.network/quran/audio/128/ar.alafasy';

  /// Ayah count per surah (1–114) for global verse index on cdn.islamic.network.
  static const _surahAyahCounts = [
    7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128,
    111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73,
    54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60,
    49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52,
    44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19,
    26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3,
    6, 3, 5, 4, 5, 6,
  ];

  static int globalAyahNumber(int surahNumber, int ayahNumber) {
    var sum = 0;
    for (var i = 0; i < surahNumber - 1 && i < _surahAyahCounts.length; i++) {
      sum += _surahAyahCounts[i];
    }
    return sum + ayahNumber;
  }

  static List<String> candidateUrls(int surahNumber, int ayahNumber) {
    final s = surahNumber.toString().padLeft(3, '0');
    final a = ayahNumber.toString().padLeft(3, '0');
    final global = globalAyahNumber(surahNumber, ayahNumber);
    return [
      '$_everyAyahBase/$s$a.mp3',
      '$_cdnBase/$global.mp3',
    ];
  }

  /// Picks first URL that responds (HEAD). Falls back to primary if check fails.
  static Future<String> resolveUrl(int surahNumber, int ayahNumber) async {
    for (final url in candidateUrls(surahNumber, ayahNumber)) {
      try {
        final res = await http
            .head(Uri.parse(url))
            .timeout(const Duration(seconds: 12));
        if (res.statusCode == 200) return url;
      } catch (_) {}
    }
    return candidateUrls(surahNumber, ayahNumber).first;
  }
}
