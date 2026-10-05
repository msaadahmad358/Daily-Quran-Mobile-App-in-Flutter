import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'translations.dart';
import 'quran_catalog_data.dart';
import 'quran_surah_detail_screen.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import 'services/quran_ayah_audio.dart';
import 'services/quran_data_service.dart';
import 'services/quran_last_read_service.dart';
import 'services/quran_reading_settings.dart';
import 'surah_name_v4_font.dart';
import 'widgets/quran_ayah_card.dart';
import 'theme/app_surfaces.dart';
import 'navigation/app_navigation.dart';
import 'widgets/app_main_drawer.dart';

// ============================================================
// QURAN TAB - WITH SEARCH
// ============================================================
class QuranTab extends StatefulWidget {
  final String currentLanguage;
  final bool isDarkMode;
  const QuranTab({
    super.key,
    required this.currentLanguage,
    this.isDarkMode = false,
  });

  @override
  State<QuranTab> createState() => _QuranTabState();
}

class _QuranTabState extends State<QuranTab> with SingleTickerProviderStateMixin {
  static const _primaryColor = Color(0xFF1A5F4A);
  static const _primaryLightColor = Color(0xFF2D7A62);
  late TabController _tabController;
  late Map<String, dynamic> _quranData;
  late List<String> _surahKeys;
  late List<String> _filteredSurahKeys;
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) setState(() {});
      });
    _quranData = {};
    _surahKeys = [];
    _filteredSurahKeys = [];
    QuranLastReadService.revision.addListener(_onLastReadChanged);
    if (QuranDataService.instance.isReady) {
      final svc = QuranDataService.instance;
      _quranData = svc.surahs;
      _surahKeys = svc.surahKeys;
      _filteredSurahKeys = svc.surahKeys;
      _isLoading = false;
    } else {
      _syncFromService();
    }
  }

  void _onLastReadChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    QuranLastReadService.revision.removeListener(_onLastReadChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _syncFromService() async {
    try {
      final svc = QuranDataService.instance;
      if (!svc.isReady) await svc.load();
      setState(() {
        _quranData = svc.surahs;
        _surahKeys = svc.surahKeys;
        _filteredSurahKeys = _surahKeys;
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load offline Quran data.';
      });
    }
  }

  void _filterSurahs(String query) {
    setState(() {
      _searchQuery = query.toLowerCase().trim();
      if (_searchQuery.isEmpty) {
        _filteredSurahKeys = _surahKeys;
        _isSearching = false;
      } else {
        _isSearching = true;
        _filteredSurahKeys = _surahKeys.where((key) {
          final surah = _quranData[key] as Map<String, dynamic>;
          final name = (surah['surah_name_en'] ?? key).toLowerCase();
          final urduName = (surah['surah_name_ur'] ?? '').toLowerCase();
          final arabicName = (surah['surah_name_ar'] ?? '').toLowerCase();
          final number = (surah['surah_number'] ?? 0).toString();
          return name.contains(_searchQuery) ||
              urduName.contains(_searchQuery) ||
              arabicName.contains(_searchQuery) ||
              number.contains(_searchQuery);
        }).toList();
      }
    });
  }

  int _getAyahCount(Map<String, dynamic> surah) {
    if (surah.containsKey('total_ayahs')) {
      final total = surah['total_ayahs'];
      if (total is int && total > 0) return total;
      if (total is String) return int.tryParse(total) ?? 0;
    }
    if (surah.containsKey('ayahs')) {
      final ayahs = surah['ayahs'];
      if (ayahs is List) return ayahs.length;
      if (ayahs is Map) return ayahs.keys.length;
    }
    return 0;
  }

  String? _surahKeyByNumber(int number) {
    for (final key in _surahKeys) {
      final surah = _quranData[key] as Map<String, dynamic>;
      if (surah['surah_number'] == number) return key;
    }
    return null;
  }

  void _openSurah(Map<String, dynamic> surah, String key, int index) {
    final isDark = widget.isDarkMode;
    final surahName = surah['surah_name_en'] ??
        surah['surah_name_ur'] ??
        key.replaceAll('_', ' ').toUpperCase();
    final surahNumber = surah['surah_number'] ?? (index + 1);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SurahDetailScreen(
          surahName: surahName,
          surahData: surah,
          surahNumber: surahNumber,
          currentLanguage: widget.currentLanguage,
          isDarkMode: isDark,
        ),
      ),
    );
  }

  void _openSurahNumber(int number) {
    final key = _surahKeyByNumber(number);
    if (key == null) return;
    final idx = _surahKeys.indexOf(key);
    _openSurah(_quranData[key] as Map<String, dynamic>, key, idx);
  }

  Color _backgroundColor(bool isDark) => AppSurfaces.scaffold(isDark);

  Color _cardColor(bool isDark) => AppSurfaces.card(isDark);

  Future<void> _openLastRead() async {
    final last = await QuranLastReadService.getLastRead();
    if (last == null) return;
    final num = last['surahNumber'] as int;
    final ayah = last['ayah'] as int;
    final key = _surahKeyByNumber(num);
    if (key == null) return;
    final surah = _quranData[key] as Map<String, dynamic>;
    final surahName = last['surahName'] as String;
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SurahDetailScreen(
          surahName: surahName,
          surahData: surah,
          surahNumber: num,
          currentLanguage: widget.currentLanguage,
          isDarkMode: widget.isDarkMode,
          initialAyah: ayah,
        ),
      ),
    );
  }

  Widget _buildContinueReadingCard(String Function(String) getText) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: QuranLastReadService.getLastRead(),
      builder: (context, snap) {
        final data = snap.data;
        if (data == null) return const SizedBox.shrink();
        final name = data['surahName'] as String;
        final ayah = data['ayah'] as int;
        return Container(
          margin: const EdgeInsets.fromLTRB(14, 6, 14, 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A5F4A), Color(0xFF2D7A62)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _openLastRead,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_fill, color: Colors.white, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getText('continueReading'),
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                          Text(
                            '$name Â· Ayah $ayah',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Resume',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _closeSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _filterSurahs('');
    });
  }

  PreferredSizeWidget _buildQuranAppBar(String Function(String) getText) {
    return AppBar(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: getText('searchSurahs'),
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: _filterSurahs,
            )
          : const Text(
              'Holy Quran',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                letterSpacing: 0.2,
              ),
            ),
      actions: [
        if (_isSearching)
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _closeSearch,
          )
        else ...[
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => openAppNotifications(context),
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => setState(() => _isSearching = true),
          ),
        ],
      ],
    );
  }

  Widget _buildHeaderBanner() {
    return SizedBox(
      height: 96,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/quran_header_bg.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _primaryColor.withValues(alpha: 0.35),
                  _primaryLightColor.withValues(alpha: 0.25),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark, String Function(String) getText) {
    final labels = [getText('surah'), getText('parah'), getText('favourites')];
    return Container(
      height: 42,
      color: _primaryColor,
      child: Row(
        children: List.generate(3, (index) {
          final selected = _tabController.index == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? _cardColor(isDark) : Colors.transparent,
                  borderRadius: selected
                      ? const BorderRadius.vertical(top: Radius.circular(3))
                      : BorderRadius.zero,
                ),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    color: selected ? _primaryColor : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSurahList(bool isDark, String Function(String) getText) {
    if (_filteredSurahKeys.isEmpty) {
      return Center(
        child: Text(
          getText('noSurahsFound'),
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _filteredSurahKeys.length,
      itemBuilder: (context, index) {
        final key = _filteredSurahKeys[index];
        final surah = _quranData[key] as Map<String, dynamic>;
        final surahName = surah['surah_name_en'] ??
            surah['surah_name_ur'] ??
            key.replaceAll('_', ' ').toUpperCase();
        final surahNumber = surah['surah_number'] ?? (index + 1);
        final ayahCount = _getAyahCount(surah);
        final num = surahNumber is int
            ? surahNumber
            : int.tryParse('$surahNumber') ?? index + 1;

        return _QuranCatalogCard(
          index: num,
          title: surahName,
          subtitle: '$ayahCount ${getText('verses')}',
          surahIdForName: num,
          primaryColor: _primaryColor,
          isDark: isDark,
          showDivider: index < _filteredSurahKeys.length - 1,
          onTap: () => _openSurah(surah, key, index),
        );
      },
    );
  }

  Widget _buildParaList(bool isDark) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: quranParas.length,
      itemBuilder: (context, i) {
        final p = quranParas[i];
        return _QuranCatalogCard(
          index: p.number,
          title: p.englishName,
          titleArabicFallback: p.arabicName,
          primaryColor: _primaryColor,
          isDark: isDark,
          showDivider: i < quranParas.length - 1,
          onTap: () {
            if (p.surahNumbers.isNotEmpty) {
              _openSurahNumber(p.surahNumbers.first);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final getText = (String key) =>
        Translations.getText(widget.currentLanguage, key);

    return Scaffold(
      backgroundColor: _backgroundColor(isDark),
      drawer: _errorMessage.isEmpty ? const AppMainDrawer() : null,
      appBar: _errorMessage.isEmpty ? _buildQuranAppBar(getText) : null,
      body: _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _syncFromService,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildHeaderBanner(),
                    _buildTabBar(isDark, getText),
                    _buildContinueReadingCard(getText),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSurahList(isDark, getText),
                          _buildParaList(isDark),
                          FavoriteAyahsScreen(
                            isDarkMode: isDark,
                            currentLanguage: widget.currentLanguage,
                            embedded: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _QuranCatalogCard extends StatelessWidget {
  final int index;
  final String title;
  final String? subtitle;
  final int? surahIdForName;
  final String? titleArabicFallback;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onTap;
  final bool showDivider;

  const _QuranCatalogCard({
    required this.index,
    required this.title,
    this.subtitle,
    this.surahIdForName,
    this.titleArabicFallback,
    required this.primaryColor,
    required this.isDark,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        isDark ? Colors.white12 : const Color(0xFFE0E0E0);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Material(
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : primaryColor,
                          ),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty)
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade500
                                  : const Color(0xFF757575),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (surahIdForName != null)
                    SizedBox(
                      width: 96,
                      child: Text(
                        SurahNameV4Font.glyph(surahIdForName!),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          fontFamily: SurahNameV4Font.family,
                          fontSize: 34,
                          height: 1.05,
                          color: isDark ? Colors.grey.shade200 : const Color(0xFF1A1A1A),
                        ),
                      ),
                    )
                  else if (titleArabicFallback != null &&
                      titleArabicFallback!.isNotEmpty)
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        titleArabicFallback!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'IndoPak',
                          fontSize: 20,
                          height: 1.3,
                          color: isDark ? Colors.grey.shade200 : Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (showDivider)
              Divider(height: 1, thickness: 1, color: dividerColor),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// FAVORITE AYAHS SCREEN
// ============================================================
class FavoriteAyahsScreen extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;
  final bool embedded;

  const FavoriteAyahsScreen({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
    this.embedded = false,
  });

  @override
  State<FavoriteAyahsScreen> createState() => _FavoriteAyahsScreenState();
}

class _FavoriteAyahsScreenState extends State<FavoriteAyahsScreen> {
  List<Map<String, dynamic>> _favoriteAyahs = [];
  bool _isLoading = true;
  Map<String, dynamic> _quranData = {};
  Set<String> _favoriteNumbers = {};
  String? _playingKey;
  AudioPlayer? _audioPlayer;
  StreamSubscription<PlayerState>? _playerSub;
  double _arabicFontSize = 26;
  String _arabicFontFamily = 'IndoPak';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<AudioPlayer> _player() async {
    if (_audioPlayer != null) return _audioPlayer!;
    final player = AudioPlayer();
    _playerSub = player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && mounted) {
        setState(() => _playingKey = null);
      }
    });
    _audioPlayer = player;
    return player;
  }

  Future<void> _playAyah(int surahNumber, int ayahNumber) async {
    final key = '$surahNumber:$ayahNumber';
    try {
      final player = await _player();
      if (_playingKey == key) {
        await player.stop();
        if (mounted) setState(() => _playingKey = null);
        return;
      }
      setState(() => _playingKey = key);
      final url = await QuranAyahAudio.resolveUrl(surahNumber, ayahNumber);
      await player.stop();
      await player.setUrl(url);
      await player.play();
    } catch (e) {
      if (!mounted) return;
      setState(() => _playingKey = null);
      final msg = e.toString().contains('MissingPluginException')
          ? 'Stop the app, run: flutter clean && flutter run'
          : 'Could not play audio. Check internet connection.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
      );
    }
  }

  void _copyAyah(String arabic, String trans, int ayahNo, String surahName) {
    Clipboard.setData(
      ClipboardData(text: '$surahName · Ayah $ayahNo\n\n$arabic\n\n$trans'),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)),
    );
  }

  void _shareAyah(String arabic, String trans, int ayahNo, String surahName) {
    Share.share('$surahName · Ayah $ayahNo\n\n$arabic\n\n$trans');
  }

  Future<void> _loadFavorites() async {
    try {
      await QuranDataService.instance.load();
      _quranData = QuranDataService.instance.surahs;
      _arabicFontSize = await QuranReadingSettings.arabicFontSize();
      final familyLabel = await QuranReadingSettings.arabicFontFamily();
      _arabicFontFamily = QuranReadingSettings.resolveFontFamily(familyLabel);

      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString('favorite_ayahs');
      if (favoritesJson != null && favoritesJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(favoritesJson);
        final Set<String> tempSet = {};
        for (var item in decoded) {
          if (item is int) {
            tempSet.add(item.toString());
          } else if (item is String) {
            tempSet.add(item);
          }
        }
        _favoriteNumbers = tempSet;

        _favoriteAyahs = [];
        for (final surahKey in _quranData.keys) {
          final surah = _quranData[surahKey] as Map<String, dynamic>;
          final surahName = surah['surah_name_en'] ?? surahKey;
          final surahNumber = surah['surah_number'] ?? 0;
          final ayahsData = surah['ayahs'];
          final ayahs = ayahsData is List
              ? ayahsData
              : ayahsData is Map
              ? ayahsData.values.toList()
              : <dynamic>[];

          for (final ayah in ayahs) {
            final ayahNumber = int.tryParse('${ayah['ayah_number']}') ?? 0;
            final favoriteKey = '$surahNumber:$ayahNumber';
            if (_favoriteNumbers.contains(favoriteKey) ||
                _favoriteNumbers.contains(ayahNumber.toString())) {
              _favoriteAyahs.add({
                'surah_name': surahName,
                'surah_number': surahNumber,
                'ayah_number': ayahNumber,
                'ayah_text': ayah['arabic_text'] ?? '',
                'translation':
                    ayah['english_mohammad_habib_shakir_translation'] ??
                    ayah['french_muhammad_hamidullah_translation'] ??
                    'Translation not available',
              });
            }
          }
        }
      }
    } catch (e) {
      // Ignore errors
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(int surahNumber, int ayahNumber) async {
    final key = '$surahNumber:$ayahNumber';
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString('favorite_ayahs');
    if (favoritesJson != null && favoritesJson.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(favoritesJson);
      final List<String> favorites = [];
      for (var item in decoded) {
        if (item is int) {
          favorites.add(item.toString());
        } else if (item is String) {
          favorites.add(item);
        }
      }
      favorites.remove(key);
      favorites.remove(ayahNumber.toString());
      await prefs.setString('favorite_ayahs', jsonEncode(favorites));
    }
    if (_playingKey == key) {
      await _audioPlayer?.stop();
      _playingKey = null;
    }
    setState(() {
      _favoriteNumbers.remove(key);
      _favoriteNumbers.remove(ayahNumber.toString());
      _favoriteAyahs.removeWhere(
        (item) =>
            item['surah_number'] == surahNumber &&
            item['ayah_number'] == ayahNumber,
      );
    });
  }

  Future<void> _clearAllFavorites() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites'),
        content: const Text(
          'Are you sure you want to remove all favorite ayahs?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('favorite_ayahs', jsonEncode([]));
      setState(() {
        _favoriteAyahs.clear();
        _favoriteNumbers.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final getText = (String key) =>
        Translations.getText(widget.currentLanguage, key);

    final body = _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteAyahs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    getText('noFavorites'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    getText('tapFavoriteIcon'),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _favoriteAyahs.length,
              itemBuilder: (context, index) {
                final ayah = _favoriteAyahs[index];
                final surahNumber = ayah['surah_number'] as int;
                final ayahNumber = ayah['ayah_number'] as int;
                final surahName = ayah['surah_name'] as String;
                final arabic = ayah['ayah_text'] as String? ?? '';
                final trans = ayah['translation'] as String? ?? '';
                final playKey = '$surahNumber:$ayahNumber';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                      child: Text(
                        surahName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: isDark
                              ? const Color(0xFF2D7A62)
                              : const Color(0xFF1A5F4A),
                        ),
                      ),
                    ),
                    QuranAyahCard(
                      ayahNumber: ayahNumber,
                      arabic: arabic,
                      translation: trans,
                      isDark: isDark,
                      isFavorite: true,
                      isPlaying: _playingKey == playKey,
                      arabicFontSize: _arabicFontSize,
                      arabicFontFamily: _arabicFontFamily,
                      onCopy: () => _copyAyah(arabic, trans, ayahNumber, surahName),
                      onFavorite: () =>
                          _removeFavorite(surahNumber, ayahNumber),
                      onPlay: () => _playAyah(surahNumber, ayahNumber),
                      onShare: () =>
                          _shareAyah(arabic, trans, ayahNumber, surahName),
                    ),
                  ],
                );
              },
            );

    if (widget.embedded) {
      return ColoredBox(
        color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F0E8),
        child: Column(
          children: [
            if (_favoriteAyahs.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _clearAllFavorites,
                  child: Text(
                    getText('clearAll'),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(
          getText('favoriteAyahs'),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_favoriteAyahs.isNotEmpty)
            TextButton(
              onPressed: _clearAllFavorites,
              child: Text(
                getText('clearAll'),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: body,
    );
  }
}
