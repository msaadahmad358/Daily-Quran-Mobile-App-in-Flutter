import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qrn_app/services/quran_ayah_audio.dart';
import 'package:qrn_app/widgets/quran_ayah_card.dart';
import 'package:qrn_app/services/quran_last_read_service.dart';
import 'package:qrn_app/services/quran_reading_settings.dart';
import 'package:qrn_app/stats.dart';
import 'package:qrn_app/surah_index_meta.dart';
import 'package:qrn_app/surah_name_v4_font.dart';
import 'package:qrn_app/quran.dart' show FavoriteAyahsScreen;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SurahDetailScreen extends StatefulWidget {
  final String surahName;
  final Map<String, dynamic> surahData;
  final int surahNumber;
  final String currentLanguage;
  final bool isDarkMode;
  final int initialAyah;

  const SurahDetailScreen({
    super.key,
    required this.surahName,
    required this.surahData,
    required this.surahNumber,
    required this.currentLanguage,
    required this.isDarkMode,
    this.initialAyah = 1,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  static const _primary = Color(0xFF1A5F4A);

  final ReadingTracker _tracker = ReadingTracker();
  final ScrollController _scrollController = ScrollController();
  AudioPlayer? _audioPlayer;
  StreamSubscription<PlayerState>? _playerSub;

  double _arabicFontSize = 26;
  String _fontLabel = 'IndoPak';
  String _fontFamily = 'IndoPak';
  Set<String> _favoriteAyahs = {};
  int _lastVisibleAyah = 1;
  Timer? _saveTimer;
  int? _playingAyah;
  SurahIndexMeta? _indexMeta;

  @override
  void initState() {
    super.initState();
    _lastVisibleAyah = widget.initialAyah;
    _loadSettings();
    _loadFavorites();
    _loadIndexMeta();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToInitialAyah());
  }

  Future<void> _loadIndexMeta() async {
    final meta = await SurahIndexMeta.forId(widget.surahNumber);
    if (mounted) setState(() => _indexMeta = meta);
  }

  Future<void> _loadSettings() async {
    final size = await QuranReadingSettings.arabicFontSize();
    final label = await QuranReadingSettings.arabicFontFamily();
    if (!mounted) return;
    setState(() {
      _arabicFontSize = size;
      _fontLabel = label;
      _fontFamily = QuranReadingSettings.resolveFontFamily(label);
    });
  }

  static const _surahHeaderScrollHeight = 132.0;
  static const _ayahScrollEstimate = 200.0;

  void _jumpToInitialAyah() {
    if (widget.initialAyah <= 1) return;
    final offset = _surahHeaderScrollHeight +
        (widget.initialAyah - 1) * _ayahScrollEstimate;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(
        offset.clamp(0, _scrollController.position.maxScrollExtent),
      );
    }
  }

  void _onScroll() {
    final contentOffset =
        _scrollController.offset - _surahHeaderScrollHeight;
    final ayah = contentOffset <= 0
        ? 1
        : (contentOffset / _ayahScrollEstimate).floor() + 1;
    if (ayah != _lastVisibleAyah && ayah >= 1) {
      _lastVisibleAyah = ayah;
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString('favorite_ayahs');
    if (favoritesJson == null || favoritesJson.isEmpty) return;
    final decoded = jsonDecode(favoritesJson) as List<dynamic>;
    final set = <String>{};
    for (final item in decoded) {
      set.add(item.toString());
    }
    if (mounted) setState(() => _favoriteAyahs = set);
  }

  String _favoriteKey(int ayah) => '${widget.surahNumber}:$ayah';

  Future<void> _toggleFavorite(int ayahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _favoriteKey(ayahNumber);
    setState(() {
      if (_favoriteAyahs.contains(key)) {
        _favoriteAyahs.remove(key);
      } else {
        _favoriteAyahs.add(key);
      }
    });
    await prefs.setString('favorite_ayahs', jsonEncode(_favoriteAyahs.toList()));
  }

  String _translation(Map<String, dynamic> ayah) {
    if (widget.currentLanguage == 'French') {
      return ayah['french_muhammad_hamidullah_translation']?.toString() ??
          ayah['english_mohammad_habib_shakir_translation']?.toString() ??
          '';
    }
    return ayah['english_mohammad_habib_shakir_translation']?.toString() ??
        ayah['english_abdullah_yusuf_ali_translation']?.toString() ??
        '';
  }

  Future<void> _copyAyah(String arabic, String trans, int ayahNo) async {
    final text = '$arabic\n\n$trans\n— ${widget.surahName} ($ayahNo)';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
    );
  }

  Future<void> _shareAyah(String arabic, String trans, int ayahNo) async {
    await Share.share(
      '$arabic\n\n$trans\n— ${widget.surahName}, Ayah $ayahNo',
    );
  }

  Future<AudioPlayer> _player() async {
    if (_audioPlayer != null) return _audioPlayer!;
    final player = AudioPlayer();
    _playerSub = player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && mounted) {
        setState(() => _playingAyah = null);
      }
    });
    _audioPlayer = player;
    return player;
  }

  Future<void> _playAyah(int ayahNo) async {
    try {
      final player = await _player();
      if (_playingAyah == ayahNo) {
        await player.stop();
        if (mounted) setState(() => _playingAyah = null);
        return;
      }

      setState(() => _playingAyah = ayahNo);
      final url = await QuranAyahAudio.resolveUrl(widget.surahNumber, ayahNo);
      await player.stop();
      await player.setUrl(url);
      await player.play();
    } catch (e) {
      if (!mounted) return;
      setState(() => _playingAyah = null);
      final msg = e.toString().contains('MissingPluginException')
          ? 'Rebuild app: flutter clean, then flutter run (full install).'
          : 'Could not play audio. Check internet connection.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
      );
    }
  }

  void _openFavoriteAyahs() {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => FavoriteAyahsScreen(
              isDarkMode: widget.isDarkMode,
              currentLanguage: widget.currentLanguage,
            ),
          ),
        )
        .then((_) {
          if (mounted) _loadFavorites();
        });
  }

  Future<void> _openReadingSettings() async {
    var size = _arabicFontSize;
    var label = _fontLabel;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reading settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: widget.isDarkMode ? Colors.white : _primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Arabic font size: ${size.toInt()}'),
                  Slider(
                    value: size,
                    min: 18,
                    max: 36,
                    activeColor: _primary,
                    onChanged: (v) => setModal(() => size = v),
                    onChangeEnd: (v) async {
                      await QuranReadingSettings.setArabicFontSize(v);
                      setState(() => _arabicFontSize = v);
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Arabic font',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: QuranReadingSettings.fontOptions.map((opt) {
                      final sel = label == opt;
                      return ChoiceChip(
                        label: Text(opt),
                        selected: sel,
                        selectedColor: _primary.withValues(alpha: 0.2),
                        onSelected: (_) async {
                          setModal(() => label = opt);
                          await QuranReadingSettings.setArabicFontFamily(opt);
                          setState(() {
                            _fontLabel = opt;
                            _fontFamily =
                                QuranReadingSettings.resolveFontFamily(opt);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<dynamic> _ayahsList() {
    final ayahsData = widget.surahData['ayahs'];
    if (ayahsData is List) return ayahsData;
    if (ayahsData is Map) return ayahsData.values.toList();
    return [];
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _scrollController.dispose();
    _playerSub?.cancel();
    _audioPlayer?.dispose();
    QuranLastReadService.save(
      surahNumber: widget.surahNumber,
      surahName: widget.surahName,
      ayahNumber: _lastVisibleAyah,
    );
    _tracker.save();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final ayahs = _ayahsList();
    final titleName = _indexMeta?.name ?? widget.surahName;
    final verseCount = _indexMeta?.ayahs ??
        int.tryParse('${widget.surahData['total_ayahs']}') ??
        ayahs.length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F0EB),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                '${widget.surahNumber}. $titleName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
          ],
        ),
        centerTitle: true,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'Bookmarks',
            onPressed: _openFavoriteAyahs,
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Reading settings',
            onPressed: _openReadingSettings,
          ),
        ],
      ),
      body: ayahs.isEmpty
          ? ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _SurahInfoCard(
                  surahNumber: widget.surahNumber,
                  surahTitle: titleName,
                  englishName:
                      widget.surahData['surah_name_en']?.toString() ?? titleName,
                  verseCount: verseCount,
                  revealedIn: _indexMeta?.revealedIn ?? 'Makkah',
                ),
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No ayahs in this surah')),
                ),
              ],
            )
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: ayahs.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _SurahInfoCard(
                    surahNumber: widget.surahNumber,
                    surahTitle: titleName,
                    englishName:
                        widget.surahData['surah_name_en']?.toString() ??
                            titleName,
                    verseCount: verseCount,
                    revealedIn: _indexMeta?.revealedIn ?? 'Makkah',
                  );
                }

                final ayahIndex = index - 1;
                final ayah = ayahs[ayahIndex] as Map<String, dynamic>;
                final ayahNo = int.tryParse('${ayah['ayah_number']}') ??
                    ayahIndex + 1;
                final arabic = ayah['arabic_text']?.toString() ?? '';
                final trans = _translation(ayah);
                final fav = _favoriteAyahs.contains(_favoriteKey(ayahNo));

                return QuranAyahCard(
                  ayahNumber: ayahNo,
                  arabic: arabic,
                  translation: trans,
                  isDark: isDark,
                  isFavorite: fav,
                  isPlaying: _playingAyah == ayahNo,
                  arabicFontSize: _arabicFontSize,
                  arabicFontFamily: _fontFamily,
                  onCopy: () => _copyAyah(arabic, trans, ayahNo),
                  onFavorite: () => _toggleFavorite(ayahNo),
                  onPlay: () => _playAyah(ayahNo),
                  onShare: () => _shareAyah(arabic, trans, ayahNo),
                );
              },
            ),
    );
  }
}

class _SurahInfoCard extends StatelessWidget {
  static const _cardBg = Color(0xFF2F5F54);
  static const _label = Color(0xFFBCAE9E);
  static const _value = Color(0xFFF3EDE4);

  final int surahNumber;
  final String surahTitle;
  final String englishName;
  final int verseCount;
  final String revealedIn;

  const _SurahInfoCard({
    required this.surahNumber,
    required this.surahTitle,
    required this.englishName,
    required this.verseCount,
    required this.revealedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Surah', surahTitle),
                const SizedBox(height: 6),
                _row('English', englishName),
                const SizedBox(height: 6),
                _row('Verses', '$verseCount'),
                const SizedBox(height: 6),
                _row('Revealed in', revealedIn),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 108,
            child: Text(
              SurahNameV4Font.glyph(surahNumber),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: const TextStyle(
                fontFamily: SurahNameV4Font.family,
                fontSize: 56,
                height: 1.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, height: 1.35),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(color: _label, fontWeight: FontWeight.w500),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(color: _value, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

