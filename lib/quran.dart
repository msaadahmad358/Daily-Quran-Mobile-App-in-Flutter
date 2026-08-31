import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrn_app/stats.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'translations.dart';

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

class _QuranTabState extends State<QuranTab> {
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
    _quranData = {};
    _surahKeys = [];
    _filteredSurahKeys = [];
    _loadQuranData();
  }

  Future<void> _loadQuranData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/quran_data.json',
      );
      final Map<String, dynamic> data = json.decode(response);

      if (data.containsKey('surahs')) {
        final surahs = data['surahs'] as Map<String, dynamic>;
        setState(() {
          _quranData = surahs;
          _surahKeys = surahs.keys.toList();
          _filteredSurahKeys = _surahKeys;
          _isLoading = false;
          _errorMessage = '';
        });
      } else {
        setState(() {
          _quranData = data;
          _surahKeys = data.keys.toList();
          _filteredSurahKeys = _surahKeys;
          _isLoading = false;
          _errorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Failed to load Quran data. Please ensure assets/quran_data.json exists.';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final getText = (String key) =>
        Translations.getText(widget.currentLanguage, key);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF5F0EB),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Search surahs...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  border: InputBorder.none,
                ),
                onChanged: _filterSurahs,
              )
            : Text(
                getText('quran'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
        backgroundColor: isDark
            ? const Color(0xFF0A0A0A)
            : const Color(0xFFF5F0EB),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _filterSurahs('');
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite, color: const Color(0xFFE74C3C)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FavoriteAyahsScreen(
                    isDarkMode: isDark,
                    currentLanguage: widget.currentLanguage,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
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
                    onPressed: _loadQuranData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _filteredSurahKeys.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No surahs found',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try searching with different keywords',
                    style: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredSurahKeys.length,
              itemBuilder: (context, index) {
                final key = _filteredSurahKeys[index];
                final surah = _quranData[key] as Map<String, dynamic>;

                final surahName =
                    surah['surah_name_en'] ??
                    surah['surah_name_ur'] ??
                    key.replaceAll('_', ' ').toUpperCase();
                final surahNumber = surah['surah_number'] ?? (index + 1);
                final ayahCount = _getAyahCount(surah);
                final arabicName = surah['surah_name_ar'] ?? '';

                return GestureDetector(
                  onTap: () {
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
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                            : [Colors.white, const Color(0xFFF8F5F0)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.2 : 0.05,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF1A5F4A),
                                const Color(0xFF2D7A62),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF1A5F4A,
                                ).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '$surahNumber',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    surahName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (arabicName.isNotEmpty)
                                    Text(
                                      arabicName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.grey[500]
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.menu_book,
                                    size: 14,
                                    color: isDark
                                        ? Colors.grey[500]
                                        : Colors.grey[400],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$ayahCount verses',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1A5F4A,
                            ).withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: const Color(0xFF1A5F4A),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ============================================================
// SURAH DETAIL SCREEN - FIXED
// ============================================================
class SurahDetailScreen extends StatefulWidget {
  final String surahName;
  final Map<String, dynamic> surahData;
  final int surahNumber;
  final String currentLanguage;
  final bool isDarkMode;

  const SurahDetailScreen({
    super.key,
    required this.surahName,
    required this.surahData,
    required this.surahNumber,
    required this.currentLanguage,
    required this.isDarkMode,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final ReadingTracker _tracker = ReadingTracker();
  DateTime? _sessionStart;
  bool _showTranslation = true;
  bool _showTafsir = true;
  final Set<int> _readAyahs = {};
  Set<String> _favoriteAyahs = {};
  int _totalAyahs = 0;
  DateTime? _lastTrackTime;
  Timer? _saveTimer;
  bool _isDisposed = false;

  String _favoriteKey(int ayahNumber) => '${widget.surahNumber}:$ayahNumber';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadFavorites();
    _sessionStart = DateTime.now();
    _lastTrackTime = DateTime.now();

    final ayahsData = widget.surahData['ayahs'];
    if (ayahsData is List) {
      _totalAyahs = ayahsData.length;
    } else if (ayahsData is Map) {
      _totalAyahs = ayahsData.keys.length;
    }

    _saveTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_readAyahs.isNotEmpty && !_isDisposed) {
        _tracker.save();
      }
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showTranslation = prefs.getBool('show_translation') ?? true;
      _showTafsir = prefs.getBool('show_tafsir') ?? true;
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString('favorite_ayahs');

    if (favoritesJson != null && favoritesJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(favoritesJson);
        final Set<String> tempSet = {};
        for (var item in decoded) {
          if (item is int) {
            tempSet.add(item.toString());
          } else if (item is String) {
            tempSet.add(item);
          }
        }
        setState(() {
          _favoriteAyahs = tempSet;
        });
      } catch (e) {
        _favoriteAyahs = {};
      }
    } else {
      _favoriteAyahs = {};
    }
  }

  Future<void> _toggleFavorite(int ayahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteKey = _favoriteKey(ayahNumber);

    setState(() {
      if (_favoriteAyahs.contains(favoriteKey)) {
        _favoriteAyahs.remove(favoriteKey);
      } else {
        _favoriteAyahs.remove(ayahNumber.toString());
        _favoriteAyahs.add(favoriteKey);
      }
    });

    final List<String> favoritesList = _favoriteAyahs.toList();
    await prefs.setString('favorite_ayahs', jsonEncode(favoritesList));
  }

  String _getTranslation(Map<String, dynamic> ayah, String language) {
    if (language == 'French') {
      return ayah['french_muhammad_hamidullah_translation'] ??
          ayah['english_mohammad_habib_shakir_translation'] ??
          ayah['english_abdullah_yusuf_ali_translation'] ??
          'Translation not available';
    } else {
      return ayah['english_mohammad_habib_shakir_translation'] ??
          ayah['english_abdullah_yusuf_ali_translation'] ??
          ayah['french_muhammad_hamidullah_translation'] ??
          'Translation not available';
    }
  }

  String _getTafsir(Map<String, dynamic> ayah) {
    return ayah['arabic_muyassar_tafseer_translation'] ??
        ayah['arabic_jalalayn_tafseer_translation'] ??
        'Tafsir not available for this verse';
  }

  void _trackAyahByIndex(int index) {
    final ayahNumber = index + 1;
    if (_readAyahs.contains(ayahNumber)) return;

    final ayahsData = widget.surahData['ayahs'];
    String ayahText = '';
    if (ayahsData is List && index < ayahsData.length) {
      ayahText = ayahsData[index]['arabic_text'] ?? '';
    } else if (ayahsData is Map) {
      final keys = ayahsData.keys.toList();
      if (index < keys.length) {
        ayahText = ayahsData[keys[index]]['arabic_text'] ?? '';
      }
    }

    int duration = 0;
    final now = DateTime.now();
    if (_lastTrackTime != null) {
      duration = now.difference(_lastTrackTime!).inSeconds;
      duration = duration.clamp(1, 300);
    }
    _lastTrackTime = now;

    _tracker.trackAyah(
      surahName: widget.surahName,
      surahNumber: widget.surahNumber,
      ayahNumber: ayahNumber,
      ayahText: ayahText,
      durationSeconds: duration,
    );

    _readAyahs.add(ayahNumber);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _isDisposed = true;
    _saveTimer?.cancel();

    if (_sessionStart != null && _readAyahs.isNotEmpty) {
      final duration = DateTime.now().difference(_sessionStart!).inSeconds;
      final sorted = _readAyahs.toList()..sort();
      _tracker.trackSession(
        surahName: widget.surahName,
        surahNumber: widget.surahNumber,
        startAyah: sorted.isNotEmpty ? sorted.first : 1,
        endAyah: sorted.isNotEmpty ? sorted.last : 1,
        totalAyahsRead: _readAyahs.length,
        durationSeconds: duration,
        ayahNumbers: sorted,
      );
    }

    _tracker.save();
    _tracker.autoSync();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final ayahsData = widget.surahData['ayahs'];
    final arabicName = widget.surahData['surah_name_ar'] ?? '';
    final isBismillah = widget.surahNumber != 9 && widget.surahNumber != 1;

    List<dynamic> ayahsList = [];
    if (ayahsData is List) {
      ayahsList = ayahsData;
    } else if (ayahsData is Map) {
      ayahsList = ayahsData.values.toList();
    }

    final surahNameArabic = widget.surahData['surah_name_ar'] ?? '';
    final revelationPlace = widget.surahData['revelation_place'] ?? '';
    final ayahCount = _totalAyahs;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) {
          await _tracker.save();
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0A0A0A)
            : const Color(0xFFF5F0EB),
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.surahName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              if (arabicName.isNotEmpty)
                Text(
                  arabicName,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
          backgroundColor: isDark
              ? const Color(0xFF0A0A0A)
              : const Color(0xFFF5F0EB),
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Row(
                  children: [
                    Icon(
                      Icons.book,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_readAyahs.length}/$_totalAyahs',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // ========== BANNER ==========
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A5F4A),
                    const Color(0xFF0D3B2E),
                    const Color(0xFF1A5F4A),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A5F4A).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (isBismillah) ...[
                    const Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.2),
                      thickness: 1,
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Surah ${widget.surahNumber}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$ayahCount verses',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (revelationPlace.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            revelationPlace,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.surahName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  if (surahNameArabic.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      surahNameArabic,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
            // ========== AYAHS LIST ==========
            Expanded(
              child: ayahsList.isEmpty
                  ? Center(
                      child: Text(
                        'No ayahs found for this surah.',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: ayahsList.length,
                      itemBuilder: (context, index) {
                        final ayah = ayahsList[index] as Map<String, dynamic>;
                        final ayahNumber =
                            int.tryParse('${ayah['ayah_number']}') ??
                            (index + 1);
                        final isRead = _readAyahs.contains(ayahNumber);
                        final isFavorite =
                            _favoriteAyahs.contains(_favoriteKey(ayahNumber)) ||
                            _favoriteAyahs.contains(ayahNumber.toString());

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!_isDisposed &&
                              !_readAyahs.contains(ayahNumber)) {
                            _trackAyahByIndex(index);
                          }
                        });

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? (isRead
                                      ? const Color(
                                          0xFF1A3A2E,
                                        ).withValues(alpha: 0.5)
                                      : const Color(0xFF1E1E1E))
                                : (isRead
                                      ? const Color(0xFFF0F5F0)
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: isRead
                                ? Border.all(
                                    color: const Color(
                                      0xFF1A5F4A,
                                    ).withValues(alpha: 0.3),
                                    width: 1.5,
                                  )
                                : Border.all(
                                    color: isDark
                                        ? const Color(0xFF3D3D3D)
                                        : const Color(0xFFE8E0D8),
                                    width: 1,
                                  ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.2 : 0.04,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ayah header with controls
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isRead
                                          ? const Color(
                                              0xFF1A5F4A,
                                            ).withValues(alpha: 0.15)
                                          : const Color(
                                              0xFF1A5F4A,
                                            ).withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'Ayah $ayahNumber',
                                      style: TextStyle(
                                        color: isRead
                                            ? const Color(0xFF1A5F4A)
                                            : isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  // ========== FAVORITE BUTTON ==========
                                  GestureDetector(
                                    onTap: () {
                                      _toggleFavorite(ayahNumber);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: isFavorite
                                            ? Colors.red.withValues(alpha: 0.1)
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFavorite
                                            ? Colors.red
                                            : isDark
                                            ? Colors.grey[500]
                                            : Colors.grey[400],
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  if (isRead)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF1A5F4A),
                                      size: 16,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Arabic text
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF2A2A2A)
                                      : const Color(0xFFF8F5F0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  ayah['arabic_text'] ?? '',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 20,
                                    height: 2.0,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Translation
                              if (_showTranslation)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey[900]
                                        : Colors.grey[50],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.translate,
                                        size: 16,
                                        color: isDark
                                            ? Colors.grey[500]
                                            : Colors.grey[400],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _getTranslation(
                                            ayah,
                                            widget.currentLanguage,
                                          ),
                                          style: TextStyle(
                                            fontSize: 14,
                                            height: 1.6,
                                            color: isDark
                                                ? Colors.grey[300]
                                                : Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Tafsir
                              if (_showTafsir)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.grey[900]
                                          : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFC9A96E,
                                        ).withValues(alpha: 0.15),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.lightbulb_outline,
                                              color: const Color(0xFFC9A96E),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '📖 Tafsir',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFFC9A96E),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _getTafsir(ayah),
                                          style: TextStyle(
                                            fontSize: 13,
                                            height: 1.6,
                                            color: isDark
                                                ? Colors.grey[300]
                                                : Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
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

  const FavoriteAyahsScreen({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
  });

  @override
  State<FavoriteAyahsScreen> createState() => _FavoriteAyahsScreenState();
}

class _FavoriteAyahsScreenState extends State<FavoriteAyahsScreen> {
  List<Map<String, dynamic>> _favoriteAyahs = [];
  bool _isLoading = true;
  Map<String, dynamic> _quranData = {};
  Set<String> _favoriteNumbers = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/quran_data.json',
      );
      final Map<String, dynamic> data = json.decode(response);
      if (data.containsKey('surahs')) {
        _quranData = data['surahs'] as Map<String, dynamic>;
      } else {
        _quranData = data;
      }

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

  Future<void> _removeFavorite(int ayahNumber) async {
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
      favorites.removeWhere(
        (favorite) =>
            favorite == ayahNumber.toString() ||
            favorite.endsWith(':$ayahNumber'),
      );
      await prefs.setString('favorite_ayahs', jsonEncode(favorites));
    }
    setState(() {
      _favoriteNumbers.removeWhere(
        (favorite) =>
            favorite == ayahNumber.toString() ||
            favorite.endsWith(':$ayahNumber'),
      );
      _favoriteAyahs.removeWhere((item) => item['ayah_number'] == ayahNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF5F0EB),
      appBar: AppBar(
        title: Text(
          '⭐ Favorite Ayahs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: isDark
            ? const Color(0xFF0A0A0A)
            : const Color(0xFFF5F0EB),
        elevation: 0,
        actions: [
          if (_favoriteAyahs.isNotEmpty)
            TextButton(
              onPressed: () async {
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
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
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
              },
              child: Text(
                'Clear All',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
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
                    'No favorite ayahs yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the ❤️ icon on any ayah to save it',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favoriteAyahs.length,
              itemBuilder: (context, index) {
                final ayah = _favoriteAyahs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFC9A96E).withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.2 : 0.04,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF1A5F4A,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${ayah['surah_name']} · Ayah ${ayah['ayah_number']}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A5F4A),
                              ),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _removeFavorite(ayah['ayah_number']),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        ayah['ayah_text'] ?? '',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 18,
                          height: 2.0,
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          ayah['translation'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
