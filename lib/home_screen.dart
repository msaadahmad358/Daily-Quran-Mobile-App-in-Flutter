import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrn_app/auth_service.dart';
import 'package:qrn_app/stats.dart';
import 'package:qrn_app/theme/app_surfaces.dart';
import 'package:qrn_app/widgets/themed_asset_icon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'translations.dart';
import 'quran.dart' hide Translations;
import 'stats.dart';
import 'settings_tab.dart';
import 'history_screen.dart';
import 'prayer_times_screen.dart';

import 'auth_service.dart';
import 'more_tab.dart';
import 'more/duas_screen.dart';
import 'more/json_guide_screen.dart';
import 'more/quran_audio_screen.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/global_surah_audio_bar.dart';
import 'widgets/app_main_drawer.dart';
import 'navigation/app_shell_scope.dart';
import 'navigation/app_navigation.dart';
import 'theme/app_arabic.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeToggle;
  final Function(String) onLanguageChange;
  final String currentLanguage;
  final bool isDarkMode;
  final VoidCallback? onUserUpdated; // â† ADD

  final VoidCallback onNavigateToQibla;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.onLanguageChange,
    required this.currentLanguage,
    required this.isDarkMode,
    this.onUserUpdated, // â† ADD

    required this.onNavigateToQibla,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;
  final AuthService _auth = AuthService();
  User? _currentUser;
  bool _navIconsPrecached = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _initializeScreens();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_navIconsPrecached) {
      _navIconsPrecached = true;
      NavTabIcon.precacheAll(context);
    }
  }

  void _loadUser() async {
    final user = await _auth.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _currentUser = user;
      _initializeScreens(); // â† rebuild screens with new user
    });
  }

  void _initializeScreens() {
    _screens = [
      HomeTab(
        isDarkMode: widget.isDarkMode,
        currentLanguage: widget.currentLanguage,

        onNavigateToQibla: widget.onNavigateToQibla,
        onNavigateToHistory: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryScreen(
                isDarkMode: widget.isDarkMode,
                currentLanguage: widget.currentLanguage,
              ),
            ),
          );
        },
        onNavigateToStatistics: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StatsScreen(
                isDarkMode: widget.isDarkMode,
                currentLanguage: widget.currentLanguage,
              ),
            ),
          );
        },
        onNavigateToQuran: () {
          setState(() {
            _selectedIndex = 1;
          });
        },
        onNavigateToSettings: () {
          setState(() {
            _selectedIndex = 4;
          });
        },
        onNavigateToPrayer: () => setState(() => _selectedIndex = 2),
        onNavigateToQuranAudio: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuranAudioScreen(
                isDarkMode: widget.isDarkMode,
                currentLanguage: widget.currentLanguage,
              ),
            ),
          );
        },
        onNavigateToHowToPray: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JsonGuideScreen(
                assetPath: 'assets/data/namaz.json',
                screenTitle: Translations.getText(
                  widget.currentLanguage,
                  'moreCardHowToPray',
                ),
                isDarkMode: widget.isDarkMode,
                currentLanguage: widget.currentLanguage,
              ),
            ),
          );
        },
        onNavigateToDuas: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DuasScreen(
                isDarkMode: widget.isDarkMode,
                currentLanguage: widget.currentLanguage,
              ),
            ),
          );
        },
        user: _currentUser,
      ),
      QuranTab(
        currentLanguage: widget.currentLanguage,
        isDarkMode: widget.isDarkMode,
      ),
      PrayerTimesScreen(
        isDarkMode: widget.isDarkMode,
        currentLanguage: widget.currentLanguage,
      ),
      MoreTab(
        isDarkMode: widget.isDarkMode,
        currentLanguage: widget.currentLanguage,
        onNavigateToQibla: widget.onNavigateToQibla,
        onNavigateToPrayer: () => setState(() => _selectedIndex = 2),
      ),
      SettingsTab(
        onThemeToggle: widget.onThemeToggle,
        onLanguageChange: widget.onLanguageChange,
        currentLanguage: widget.currentLanguage,
        isDarkMode: widget.isDarkMode,
        onUserUpdated: widget.onUserUpdated, // â† ADD
      ),
    ];
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initializeScreens();
  }

  Future<void> _confirmExitApp() async {
    final lang = widget.currentLanguage;
    final quit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(Translations.getText(lang, 'exitAppTitle')),
        content: Text(Translations.getText(lang, 'exitAppMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(Translations.getText(lang, 'exitAppNo')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A5F4A),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(Translations.getText(lang, 'exitAppYes')),
          ),
        ],
      ),
    );
    if (quit == true && mounted) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final getText = (String key) =>
        Translations.getText(widget.currentLanguage, key);

    return AppShellScope(
      selectedTab: _selectedIndex,
      onSelectTab: (index) {
        setState(() => _selectedIndex = index);
        if (index == 0 || index == 4) _loadUser();
      },
      isDarkMode: widget.isDarkMode,
      currentLanguage: widget.currentLanguage,
      user: _currentUser,
      onQibla: widget.onNavigateToQibla,
      onDuas: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DuasScreen(
              isDarkMode: widget.isDarkMode,
              currentLanguage: widget.currentLanguage,
            ),
          ),
        );
      },
      onQuranAudio: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuranAudioScreen(
              isDarkMode: widget.isDarkMode,
              currentLanguage: widget.currentLanguage,
            ),
          ),
        );
      },
      onHowToPray: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JsonGuideScreen(
              assetPath: 'assets/data/namaz.json',
              screenTitle: getText('moreCardHowToPray'),
              isDarkMode: widget.isDarkMode,
              currentLanguage: widget.currentLanguage,
            ),
          ),
        );
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          if (_selectedIndex != 0) {
            setState(() => _selectedIndex = 0);
            return;
          }
          await _confirmExitApp();
        },
        child: Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlobalSurahAudioBar(
                isDarkMode: widget.isDarkMode,
                currentLanguage: widget.currentLanguage,
              ),
              AppBottomNav(
                selectedIndex: _selectedIndex,
                isDarkMode: widget.isDarkMode,
                labels: [
                  getText('home'),
                  getText('quran'),
                  getText('prayer'),
                  getText('more'),
                  getText('settings'),
                ],
                onTap: (index) {
                  setState(() => _selectedIndex = index);
                  if (index == 0 || index == 4) {
                    _loadUser();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ HOME TAB ============
class HomeTab extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;

  final VoidCallback onNavigateToQibla;
  final VoidCallback onNavigateToHistory;
  final VoidCallback onNavigateToStatistics;
  final VoidCallback onNavigateToQuran;
  final VoidCallback onNavigateToSettings;
  final VoidCallback onNavigateToPrayer;
  final VoidCallback onNavigateToQuranAudio;
  final VoidCallback onNavigateToHowToPray;
  final VoidCallback onNavigateToDuas;
  final User? user;

  const HomeTab({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,

    required this.onNavigateToQibla,
    required this.onNavigateToHistory,
    required this.onNavigateToStatistics,
    required this.onNavigateToQuran,
    required this.onNavigateToSettings,
    required this.onNavigateToPrayer,
    required this.onNavigateToQuranAudio,
    required this.onNavigateToHowToPray,
    required this.onNavigateToDuas,
    this.user,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const _primary = Color(0xFF1A5F4A);
  static const _primaryLight = Color(0xFF2D7A62);
  static const _pagePadding = EdgeInsets.fromLTRB(14, 12, 14, 24);

  /// Same cell height as More tab grid cards.
  static const _shortcutAspectRatio = 2.05 * 1.05 * 1.05;

  static const _stripeColors = [
    Color(0xFF1A5F4A),
    Color(0xFF1565C0),
    Color(0xFF6B8F7A),
    Color(0xFF2E86C1),
    Color(0xFFF57C00),
    Color(0xFF7B1FA2),
  ];

  final ReadingTracker _tracker = ReadingTracker();
  ReadingSummary? _summary;
  bool _isLoadingStats = true;
  List<ReadingSession> _recentSessions = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoadingStats = true);
    await _tracker.refresh();
    setState(() {
      _summary = _tracker.getSummary();
      _recentSessions = _tracker.getRecentSessions(limit: 3);
      _isLoadingStats = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final getText = (String key) =>
        Translations.getText(widget.currentLanguage, key);

    return Scaffold(
      backgroundColor: AppSurfaces.scaffold(isDark),
      drawer: const AppMainDrawer(),
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          getText('home'),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => openAppNotifications(context),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            onPressed: widget.onNavigateToSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final innerWidth = constraints.maxWidth - _pagePadding.horizontal;
          final halfCellWidth = (innerWidth - 12) / 2;
          final shortcutHeight = halfCellWidth / _shortcutAspectRatio;

          return SingleChildScrollView(
            padding: _pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAyatOfTheDayCard(isDark, getText),
                const SizedBox(height: 12),
                _buildHadithOfTheDayCard(isDark, getText),
                const SizedBox(height: 12),
                _buildDonateNowButton(isDark, getText),
                const SizedBox(height: 12),
                SizedBox(
                  height: shortcutHeight,
                  child: _HomeShortcutCard(
                    isDark: isDark,
                    data: _HomeShortcutData(
                      title: getText('readQuran'),
                      asset: 'assets/images/more/read_quran.png',
                      stripeColor: _stripeColors[0],
                      onTap: widget.onNavigateToQuran,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildShortcutRow(
                  isDark: isDark,
                  height: shortcutHeight,
                  left: _HomeShortcutData(
                    title: getText('history'),
                    asset: 'assets/images/more/history.png',
                    stripeColor: _stripeColors[2],
                    onTap: widget.onNavigateToHistory,
                  ),
                  right: _HomeShortcutData(
                    title: getText('stats'),
                    asset: 'assets/images/more/stats.png',
                    stripeColor: _stripeColors[3],
                    onTap: widget.onNavigateToStatistics,
                  ),
                ),
                const SizedBox(height: 12),
                _buildShortcutRow(
                  isDark: isDark,
                  height: shortcutHeight,
                  left: _HomeShortcutData(
                    title: getText('moreCardHowToPray'),
                    asset: 'assets/images/more/namaz_tariqa.png',
                    stripeColor: _stripeColors[4],
                    onTap: widget.onNavigateToHowToPray,
                  ),
                  right: _HomeShortcutData(
                    title: getText('moreCardQuranAudio'),
                    asset: 'assets/images/more/quran_audio.png',
                    stripeColor: _stripeColors[1],
                    onTap: widget.onNavigateToQuranAudio,
                  ),
                ),
                const SizedBox(height: 16),
                _buildReadingProgress(isDark, getText),
                const SizedBox(height: 12),
                _buildRecentActivity(isDark, getText),
                const SizedBox(height: 20),
                _buildWebsiteLink(getText),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openDonate(String Function(String) getText) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = await AuthService().donateUri(widget.currentLanguage);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text(getText('couldNotOpenDonation'))),
      );
    }
  }

  Widget _buildDonateNowButton(
    bool isDark,
    String Function(String) getText,
  ) {
    // Same background as the Ayat/Hadith cards (image + green overlay).
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _verseBgAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  ColoredBox(color: _primary),
            ),
            Container(
              color: Color.lerp(
                _primary.withValues(alpha: 0.78),
                Colors.black.withValues(alpha: 0.5),
                isDark ? 0.5 : 0.3,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                key: const Key('homeDonateNow'),
                onTap: () => _openDonate(getText),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      color: _goldAccent,
                      size: 22,
                      shadows: [Shadow(blurRadius: 6, color: Colors.black45)],
                    ),
                    const SizedBox(width: 10),
                    Text(
                      getText('donateNow'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        shadows: [Shadow(blurRadius: 6, color: Colors.black45)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _websiteUrl = 'http://hassana.eu';

  Widget _buildWebsiteLink(String Function(String) getText) {
    return OutlinedButton.icon(
      onPressed: () async {
        final uri = Uri.parse(_websiteUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      icon: const Icon(Icons.public_rounded),
      label: Text(getText('visitWebsite')),
      style: OutlinedButton.styleFrom(
        foregroundColor: _primary,
        side: const BorderSide(color: _primary),
        minimumSize: const Size.fromHeight(48),
      ),
    );
  }

  static const _verseBgAsset = 'assets/images/home/home_verse_bg.jpg';
  static const _goldAccent = Color(0xFFC9A96E);

  Widget _buildAyatOfTheDayCard(
    bool isDark,
    String Function(String) getText,
  ) {
    return _buildThemedDayCard(
      isDark: isDark,
      title: getText('ayatOfTheDay'),
      mainText: getText('todayVerseArabic'),
      translation: getText('verseTranslationFr'),
      useArabicFont: true,
      arabicMaxLines: 3,
      translationMaxLines: 3,
      cardHeight: 162,
      overlay: Color.lerp(
        _primary.withValues(alpha: 0.78),
        Colors.black.withValues(alpha: 0.5),
        isDark ? 0.5 : 0.3,
      )!,
    );
  }

  Widget _buildHadithOfTheDayCard(
    bool isDark,
    String Function(String) getText,
  ) {
    return _buildThemedDayCard(
      isDark: isDark,
      title: getText('hadithOfTheDay'),
      mainText: getText('todayHadithArabic'),
      translation: getText('todayHadithTranslationFr'),
      useArabicFont: true,
      overlay: Color.lerp(
        _primaryLight.withValues(alpha: 0.75),
        _goldAccent.withValues(alpha: 0.45),
        isDark ? 0.65 : 0.4,
      )!,
    );
  }

  Widget _buildThemedDayCard({
    required bool isDark,
    required String title,
    required String mainText,
    required String translation,
    required Color overlay,
    bool useArabicFont = false,
    int arabicMaxLines = 2,
    int translationMaxLines = 2,
    double cardHeight = 118,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: cardHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _verseBgAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  ColoredBox(color: _primary),
            ),
            Container(color: overlay),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      color: Colors.white.withValues(alpha: 0.95),
                      shadows: const [
                        Shadow(blurRadius: 4, color: Colors.black38),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          mainText,
                          textAlign: TextAlign.center,
                          maxLines: arabicMaxLines,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily:
                                useArabicFont ? AppArabic.fontFamily : null,
                            fontSize: useArabicFont ? 15 : 14,
                            height: 1.28,
                            color: Colors.white,
                            shadows: const [
                              Shadow(blurRadius: 6, color: Colors.black45),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Center(
                            child: Container(
                              width: 52,
                              height: 1,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            translation,
                            textAlign: TextAlign.center,
                            maxLines: translationMaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              height: 1.22,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withValues(alpha: 0.92),
                              shadows: const [
                                Shadow(blurRadius: 4, color: Colors.black38),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutRow({
    required bool isDark,
    required double height,
    required _HomeShortcutData left,
    required _HomeShortcutData right,
  }) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _HomeShortcutCard(isDark: isDark, data: left),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _HomeShortcutCard(isDark: isDark, data: right),
          ),
        ],
      ),
    );
  }

  Widget _homeSectionCard({
    required bool isDark,
    required String title,
    required Widget child,
  }) {
    final bg = AppSurfaces.card(isDark);
    return Material(
      color: bg,
      elevation: isDark ? 0 : 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(3),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A2E35),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }


  // ========== READING PROGRESS - DYNAMIC ==========
  Widget _buildReadingProgress(bool isDark, String Function(String) getText) {
    if (_isLoadingStats) {
      return _homeSectionCard(
        isDark: isDark,
        title: getText('readingProgress'),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
        ),
      );
    }

    final summary = _summary;
    if (summary == null) {
      return _buildReadingProgressStatic(isDark, getText);
    }

    // Calculate Quran progress percentage (based on total verses read)
    final totalVerses = summary.totalVerses;
    final quranTotal = 6236; // Total verses in Quran
    final progressPercent = (totalVerses / quranTotal * 100).clamp(0, 100);
    final surahsCompleted = summary.surahsCompleted;
    final streak = summary.currentStreak;
    final todayVerses = summary.todayVerses;

    return _homeSectionCard(
      isDark: isDark,
      title: getText('readingProgress'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${summary.quranProgress.toStringAsFixed(1)}% ${getText('percentOfQuran')}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '${progressPercent.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (progressPercent / 100).clamp(0, 1),
              backgroundColor: isDark
                  ? Colors.grey[850]
                  : const Color(0xFFE8E0D8),
              valueColor: const AlwaysStoppedAnimation<Color>(_primary),
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStat(
                Icons.menu_book_outlined,
                '$totalVerses ${getText('verses')}',
                isDark,
              ),
              _buildProgressStat(
                Icons.library_books_outlined,
                '$surahsCompleted ${getText('surahs')}',
                isDark,
              ),
              _buildProgressStat(
                Icons.local_fire_department_outlined,
                '$streak ${getText('dayStreak')}',
                isDark,
              ),
            ],
          ),
          if (todayVerses > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFC9A96E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFC9A96E).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.today, color: Color(0xFFC9A96E), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '$todayVerses ${getText('verses')} ${getText('today')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFFC9A96E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Fallback static progress
  Widget _buildReadingProgressStatic(
    bool isDark,
    String Function(String) getText,
  ) {
    return _homeSectionCard(
      isDark: isDark,
      title: getText('readingProgress'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '0% ${getText('completed')}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: 0,
              backgroundColor: isDark
                  ? Colors.grey[850]
                  : const Color(0xFFE8E0D8),
              valueColor: const AlwaysStoppedAnimation<Color>(_primary),
              minHeight: 7,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStat(
                Icons.menu_book_outlined,
                '0 ${getText('verses')}',
                isDark,
              ),
              _buildProgressStat(
                Icons.library_books_outlined,
                '0 ${getText('surahs')}',
                isDark,
              ),
              _buildProgressStat(
                Icons.local_fire_department_outlined,
                '0 ${getText('dayStreak')}',
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(IconData icon, String label, bool isDark) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: _primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== FEATURED SURAHS ==========

  // ========== RECENT ACTIVITY - DYNAMIC ==========
  Widget _buildRecentActivity(bool isDark, String Function(String) getText) {
    if (_isLoadingStats) {
      return _homeSectionCard(
        isDark: isDark,
        title: getText('recentActivity'),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
        ),
      );
    }

    final sessions = _recentSessions.take(3).toList();

    if (sessions.isEmpty) {
      return _homeSectionCard(
        isDark: isDark,
        title: getText('recentActivity'),
        child: Column(
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 40,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 10),
            Text(
              getText('noHistory'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: widget.onNavigateToQuran,
              child: Text(
                getText('startReadingHistory'),
                style: const TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _homeSectionCard(
      isDark: isDark,
      title: getText('recentActivity'),
      child: Column(
        children: [
          for (var i = 0; i < sessions.length; i++) ...[
            if (i > 0)
              Divider(
                height: 20,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
              ),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Icon(
                    Icons.menu_book_outlined,
                    color: _primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Read ${sessions[i].surahName}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isDark ? Colors.white : const Color(0xFF1A2E35),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getTimeAgo(sessions[i].endTime),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (_recentSessions.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onNavigateToHistory,
                  child: Text(
                    'View all (${_recentSessions.length})',
                    style: const TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays > 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inHours > 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours == 1) {
      return '1 hour ago';
    } else if (difference.inMinutes > 5) {
      return '${difference.inMinutes} min ago';
    } else {
      return 'Just now';
    }
  }
}

class _HomeShortcutData {
  const _HomeShortcutData({
    required this.title,
    required this.stripeColor,
    required this.onTap,
    this.asset,
    this.icon,
  });

  final String title;
  final String? asset;
  final IconData? icon;
  final Color stripeColor;
  final VoidCallback onTap;
}

class _HomeShortcutCard extends StatelessWidget {
  const _HomeShortcutCard({
    required this.isDark,
    required this.data,
  });

  final bool isDark;
  final _HomeShortcutData data;

  static const _iconSize = 46.0 * 1.15 * 1.10 * 1.15 * 1.15;
  static const _stripeWidth = 5.0;

  @override
  Widget build(BuildContext context) {
    final bg = AppSurfaces.card(isDark);

    return Material(
      color: bg,
      elevation: isDark ? 0 : 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(3),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: data.onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: _stripeWidth, color: data.stripeColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 18, 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    data.asset != null
                        ? ThemedAssetIcon(
                            asset: data.asset!,
                            isDark: isDark,
                            size: _iconSize,
                            surfaceColor: bg,
                          )
                        : SizedBox(
                            width: _iconSize,
                            height: _iconSize,
                            child: Icon(
                              data.icon ?? Icons.circle_outlined,
                              size: 34,
                              color: data.stripeColor,
                            ),
                          ),
                    const SizedBox(width: 4),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        data.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          height: 1.12,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A2E35),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ WEBSITE SCREEN ============
class WebsiteScreen extends StatelessWidget {
  const WebsiteScreen({super.key});

  static const String _websiteUrl = 'http://hassana.eu';

  Future<void> _launchWebsite() async {
    try {
      final Uri url = Uri.parse(_websiteUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: Show dialog if can't launch
        _showCannotLaunchDialog();
      }
    } catch (e) {
      // Fallback: Show dialog on error
      _showCannotLaunchDialog();
    }
  }

  void _showCannotLaunchDialog() {
    // Get context from the current build context
    // This will be called from the build method context
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLanguage = 'French'; // Get from provider if needed

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF5F0EB),
      appBar: AppBar(
        title: Text(Translations.getText(currentLanguage, 'hassanaEu')),
        backgroundColor: isDark
            ? const Color(0xFF0A0A0A)
            : const Color(0xFFF5F0EB),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ===== FIXED: GestureDetector with proper onTap =====
            GestureDetector(
              onTap: _launchWebsite,
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A5F4A),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A5F4A).withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.public, color: Colors.white, size: 60),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              Translations.getText(currentLanguage, 'visitWebsite'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              Translations.getText(currentLanguage, 'forMoreResources'),
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _launchWebsite,
              icon: const Icon(Icons.open_in_browser),
              label: Text(Translations.getText(currentLanguage, 'openWebsite')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A5F4A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
