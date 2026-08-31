import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrn_app/auth_service.dart';
import 'package:qrn_app/stats.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'translations.dart';
import 'quran.dart' hide Translations;
import 'stats.dart';
import 'settings_tab.dart';
import 'history_screen.dart';
import 'prayer_times_screen.dart';

import 'auth_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeToggle;
  final Function(String) onLanguageChange;
  final String currentLanguage;
  final bool isDarkMode;
  final VoidCallback onNavigateToSubscription;
  final VoidCallback onNavigateToDonation;
  final VoidCallback onNavigateToQibla;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.onLanguageChange,
    required this.currentLanguage,
    required this.isDarkMode,
    required this.onNavigateToSubscription,
    required this.onNavigateToDonation,
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

  @override
  void initState() {
    super.initState();
    _loadUser();
    _initializeScreens();
  }

  void _loadUser() async {
    final user = await _auth.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  void _initializeScreens() {
    _screens = [
      HomeTab(
        isDarkMode: widget.isDarkMode,
        currentLanguage: widget.currentLanguage,
        onNavigateToSubscription: widget.onNavigateToSubscription,
        onNavigateToDonation: widget.onNavigateToDonation,
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
            _selectedIndex = 3;
          });
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
      SettingsTab(
        onThemeToggle: widget.onThemeToggle,
        onLanguageChange: widget.onLanguageChange,
        currentLanguage: widget.currentLanguage,
        isDarkMode: widget.isDarkMode,
      ),
    ];
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initializeScreens();
  }

  @override
  Widget build(BuildContext context) {
    final getText = (String key) =>
        Translations.getText(widget.currentLanguage, key);

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: widget.isDarkMode
              ? const Color(0xFF1A1A1A)
              : Colors.white,
          selectedItemColor: const Color(0xFF1A5F4A),
          unselectedItemColor: widget.isDarkMode
              ? Colors.grey[600]
              : Colors.grey[400],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
              ),
              label: getText('home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 1 ? Icons.book : Icons.book_outlined,
              ),
              label: getText('quran'),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 2 ? Icons.mosque : Icons.mosque_outlined,
              ),
              label: getText('qiblaDirection'),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 3 ? Icons.settings : Icons.settings_outlined,
              ),
              label: getText('settings'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ HOME TAB ============
class HomeTab extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;
  final VoidCallback onNavigateToSubscription;
  final VoidCallback onNavigateToDonation;
  final VoidCallback onNavigateToQibla;
  final VoidCallback onNavigateToHistory;
  final VoidCallback onNavigateToStatistics;
  final VoidCallback onNavigateToQuran;
  final VoidCallback onNavigateToSettings;
  final User? user;

  const HomeTab({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
    required this.onNavigateToSubscription,
    required this.onNavigateToDonation,
    required this.onNavigateToQibla,
    required this.onNavigateToHistory,
    required this.onNavigateToStatistics,
    required this.onNavigateToQuran,
    required this.onNavigateToSettings,
    this.user,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
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

  String _getDailyMessage() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final messageIndex = (dayOfYear % 8) + 1;
    return Translations.getText(
      widget.currentLanguage,
      'dailyMessage$messageIndex',
    );
  }

  String _getTodayDate() {
    final now = DateTime.now();
    final weekdays = [
      Translations.getText(widget.currentLanguage, 'monday'),
      Translations.getText(widget.currentLanguage, 'tuesday'),
      Translations.getText(widget.currentLanguage, 'wednesday'),
      Translations.getText(widget.currentLanguage, 'thursday'),
      Translations.getText(widget.currentLanguage, 'friday'),
      Translations.getText(widget.currentLanguage, 'saturday'),
      Translations.getText(widget.currentLanguage, 'sunday'),
    ];
    final months = [
      Translations.getText(widget.currentLanguage, 'january'),
      Translations.getText(widget.currentLanguage, 'february'),
      Translations.getText(widget.currentLanguage, 'march'),
      Translations.getText(widget.currentLanguage, 'april'),
      Translations.getText(widget.currentLanguage, 'may'),
      Translations.getText(widget.currentLanguage, 'june'),
      Translations.getText(widget.currentLanguage, 'july'),
      Translations.getText(widget.currentLanguage, 'august'),
      Translations.getText(widget.currentLanguage, 'september'),
      Translations.getText(widget.currentLanguage, 'october'),
      Translations.getText(widget.currentLanguage, 'november'),
      Translations.getText(widget.currentLanguage, 'december'),
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final getText = (String key) =>
        Translations.getText(widget.currentLanguage, key);
    final userName = widget.user?.name ?? 'Guest';
    final dailyMessage = _getDailyMessage();
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : '👤';

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF5F0EB),
      body: Column(
        children: [
          // ========== SIMPLE APP BAR ==========
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF1A3A2E),
                        const Color(0xFF0D2B1E),
                        const Color(0xFF1A5F4A),
                      ]
                    : [
                        const Color(0xFF1A5F4A),
                        const Color(0xFF0D3B2E),
                        const Color(0xFF1A5F4A),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFC9A96E), Color(0xFFE8D5A3)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFC9A96E,
                                ).withValues(alpha: 0.3),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1A5F4A),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                userInitial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '🌙 ${getText('appTitle')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: widget.onNavigateToSettings,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.settings_outlined,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${getText('salam')}, $userName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.white.withValues(alpha: 0.6),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getTodayDate(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ========== SCROLLABLE CONTENT ==========
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVerseOfTheDay(isDark, getText),
                  const SizedBox(height: 20),
                  _buildDailyInspiration(isDark, getText, dailyMessage),
                  const SizedBox(height: 20),
                  _buildQuickActionsGrid(isDark, getText),
                  const SizedBox(height: 20),
                  _buildReadingProgress(isDark, getText),

                  const SizedBox(height: 20),
                  _buildRecentActivity(isDark, getText),
                  const SizedBox(height: 20),
                  _buildWebsiteLink(isDark, getText),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== 📖 VERSE OF THE DAY ==========
  Widget _buildVerseOfTheDay(bool isDark, String Function(String) getText) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A3A2E),
                  const Color(0xFF0D2B1E),
                  const Color(0xFF0D3B2E),
                ]
              : [
                  const Color(0xFF1A5F4A),
                  const Color(0xFF0D3B2E),
                  const Color(0xFF1A5F4A),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF0D2B1E) : const Color(0xFF1A5F4A))
                .withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC9A96E).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_stories,
                    color: Color(0xFFC9A96E),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getText('verseOfTheDay'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // ===== FIXED: Using translation =====
                    Text(
                      getText('todayVerse'),
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    getText('today'),
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: const Center(
                child: Text(
                  'وَيُطْعِمُونَ الْطَعَامَ عَلَى حَبِيهِ\nمِسْكِينًا وَيَتَيْمًا وَأَسِيرًا',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    height: 2.2,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.translate,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        getText('translation'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // ===== FIXED: Using translation =====
                  Text(
                    getText('verseTranslation'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getText('translationCredit'),
                    style: TextStyle(color: Colors.white60, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      getText('tafsir'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withValues(alpha: 0.2),
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== 🤲 INSPIRING DAILY MESSAGE ==========
  Widget _buildDailyInspiration(
    bool isDark,
    String Function(String) getText,
    String message,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, const Color(0xFFF8F5F0)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? const Color(0xFF3D3D3D)
              : const Color(0xFFC9A96E).withValues(alpha: 0.15),
          width: isDark ? 0 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFC9A96E), const Color(0xFFE8D5A3)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getText('dailyInspiration'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFC9A96E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== QUICK ACTIONS GRID ==========
  Widget _buildQuickActionsGrid(bool isDark, String Function(String) getText) {
    final actions = [
      {
        'icon': Icons.auto_stories,
        'label': getText('readQuran'),
        'color': const Color(0xFF1A5F4A),
        'tap': widget.onNavigateToQuran,
      },
      {
        'icon': Icons.mosque,
        'label': getText('prayerTimes'),
        'color': const Color(0xFFC9A96E),
        'tap': widget.onNavigateToQibla,
      },
      {
        'icon': Icons.history,
        'label': getText('history'),
        'color': const Color(0xFF6B8F7A),
        'tap': widget.onNavigateToHistory,
      },
      {
        'icon': Icons.show_chart,
        'label': getText('stats'),
        'color': const Color(0xFF2E86C1),
        'tap': widget.onNavigateToStatistics,
      },
      {
        'icon': Icons.star_outline,
        'label': getText('subscription'),
        'color': const Color(0xFF9B59B6),
        'tap': widget.onNavigateToSubscription,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildQuickAction(
          icon: action['icon'] as IconData,
          label: action['label'] as String,
          color: action['color'] as Color,
          isDark: isDark,
          onTap: action['tap'] as VoidCallback,
        );
      },
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ========== READING PROGRESS - DYNAMIC ==========
  Widget _buildReadingProgress(bool isDark, String Function(String) getText) {
    if (_isLoadingStats) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                : [Colors.white, const Color(0xFFF8F5F0)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: CircularProgressIndicator(),
          ),
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, const Color(0xFFF8F5F0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A5F4A), Color(0xFF2D7A62)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getText('readingProgress'),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '${summary.quranProgress.toStringAsFixed(1)}% ${getText('percentOfQuran')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A5F4A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${progressPercent.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Color(0xFF1A5F4A),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (progressPercent / 100).clamp(0, 1),
              backgroundColor: isDark
                  ? Colors.grey[800]
                  : const Color(0xFFE8E0D8),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1A5F4A),
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStat(
                '📖',
                '$totalVerses ${getText('verses')}',
                isDark,
              ),
              _buildProgressStat(
                '📚',
                '$surahsCompleted ${getText('surahs')}',
                isDark,
              ),
              _buildProgressStat(
                '🔥',
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, const Color(0xFFF8F5F0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A5F4A), Color(0xFF2D7A62)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getText('readingProgress'),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '0% ${getText('completed')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A5F4A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '0%',
                  style: TextStyle(
                    color: Color(0xFF1A5F4A),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0,
              backgroundColor: isDark
                  ? Colors.grey[800]
                  : const Color(0xFFE8E0D8),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1A5F4A),
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressStat('📖', '0 ${getText('verses')}', isDark),
              _buildProgressStat('📚', '0 ${getText('surahs')}', isDark),
              _buildProgressStat('🔥', '0 ${getText('dayStreak')}', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String emoji, String label, bool isDark) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  // ========== FEATURED SURAHS ==========

  // ========== RECENT ACTIVITY - DYNAMIC ==========
  Widget _buildRecentActivity(bool isDark, String Function(String) getText) {
    if (_isLoadingStats) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                : [Colors.white, const Color(0xFFF8F5F0)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Build activity list from recent sessions
    List<Map<String, String>> activities = [];
    if (_recentSessions.isNotEmpty) {
      activities = _recentSessions.take(3).map((session) {
        final timeAgo = _getTimeAgo(session.endTime);
        return {
          'title': 'Read ${session.surahName}',
          'subtitle': '$timeAgo',
          'icon': '📖',
        };
      }).toList();
    }

    // If no history, show empty state
    if (activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                : [Colors.white, const Color(0xFFF8F5F0)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getText('recentActivity'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    getText('noHistory'),
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: widget.onNavigateToQuran,
                    child: Text(
                      getText('startReadingHistory'),
                      style: TextStyle(color: const Color(0xFF1A5F4A)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, const Color(0xFFF8F5F0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getText('recentActivity'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...activities.map(
            (activity) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text(
                    activity['icon'] as String,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['title'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          activity['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A5F4A),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_recentSessions.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: TextButton(
                  onPressed: widget.onNavigateToHistory,
                  child: Text(
                    'View All (${_recentSessions.length})',
                    style: TextStyle(
                      color: const Color(0xFF1A5F4A),
                      fontWeight: FontWeight.w600,
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

  // ========== 🌐 WEBSITE LINK ==========
  Widget _buildWebsiteLink(bool isDark, String Function(String) getText) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, const Color(0xFFF8F5F0)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? const Color(0xFF3D3D3D)
              : const Color(0xFF1A5F4A).withValues(alpha: 0.15),
          width: isDark ? 0 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WebsiteScreen()),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF1A5F4A), const Color(0xFF2D7A62)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.public, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getText('website'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'hassana.eu',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A5F4A).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: const Color(0xFF1A5F4A),
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
