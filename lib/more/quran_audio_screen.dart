import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qrn_app/services/global_surah_audio_service.dart';
import 'package:qrn_app/services/quran_data_service.dart';
import 'package:qrn_app/translations.dart';
import 'package:qrn_app/widgets/more_page_scaffold.dart';

class QuranAudioScreen extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;

  const QuranAudioScreen({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
  });

  @override
  State<QuranAudioScreen> createState() => _QuranAudioScreenState();
}

class _QuranAudioScreenState extends State<QuranAudioScreen> {
  static const _primary = Color(0xFF1A5F4A);

  late Map<String, dynamic> _quranData;
  late List<String> _keys;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final svc = QuranDataService.instance;
    if (!svc.isReady) await svc.load();
    setState(() {
      _quranData = svc.surahs;
      _keys = svc.surahKeys;
      _loading = false;
    });
  }

  int _ayahCount(Map<String, dynamic> surah) {
    if (surah.containsKey('total_ayahs')) {
      final t = surah['total_ayahs'];
      if (t is int) return t;
      return int.tryParse('$t') ?? 0;
    }
    final ayahs = surah['ayahs'];
    if (ayahs is List) return ayahs.length;
    if (ayahs is Map) return ayahs.length;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final audio = context.watch<GlobalSurahAudioService>();

    final versesLabel =
        Translations.getText(widget.currentLanguage, 'verses');

    return MorePageScaffold(
      title: Translations.getText(widget.currentLanguage, 'moreCardQuranAudio'),
      isDarkMode: isDark,
      currentLanguage: widget.currentLanguage,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _keys.length,
              itemBuilder: (context, index) {
                final key = _keys[index];
                final surah = _quranData[key] as Map<String, dynamic>;
                final name = surah['surah_name_en']?.toString() ??
                    key.replaceAll('_', ' ');
                final num = surah['surah_number'] is int
                    ? surah['surah_number'] as int
                    : int.tryParse('${surah['surah_number']}') ?? index + 1;
                final playing =
                    audio.isActive && audio.surahNumber == num && audio.isPlaying;

                return Material(
                  color: card,
                  child: ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '$num',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : _primary,
                      ),
                    ),
                    subtitle: Text('${_ayahCount(surah)} $versesLabel'),
                    trailing: Icon(
                      playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: _primary,
                      size: 32,
                    ),
                    onTap: () {
                      if (audio.surahNumber == num && audio.isActive) {
                        audio.togglePlayPause();
                      } else {
                        audio.playSurah(num, displayName: name);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
