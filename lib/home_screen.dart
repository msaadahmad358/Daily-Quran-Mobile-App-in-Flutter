import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrn_app/auth_service.dart';
import 'package:qrn_app/stats.dart';
import 'dart:convert';
import 'main.dart';
import 'quran.dart' hide AppTranslations;
import 'stats.dart';
import 'settings_tab.dart';
import 'history_screen.dart';

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
        user: _currentUser,
      ),
      QuranTab(
        currentLanguage: widget.currentLanguage,
        isDarkMode: widget.isDarkMode,
      ),
      StatsScreen(
        currentLanguage: widget.currentLanguage,
        isDarkMode: widget.isDarkMode,
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
        AppTranslations.getText(widget.currentLanguage, key);

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
              label: getText('today'),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 1 ? Icons.book : Icons.book_outlined,
              ),
              label: getText('quran'),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 2
                    ? Icons
                          .bar_chart // ← Changed from handshake
                    : Icons.bar_chart_outlined,
              ),
              label: 'Stats',
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

// ============ HOME TAB - SMOOTH SLIVER APP BAR ============
class HomeTab extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;
  final VoidCallback onNavigateToSubscription;
  final VoidCallback onNavigateToDonation;
  final VoidCallback onNavigateToQibla;
  final VoidCallback onNavigateToHistory;
  final VoidCallback onNavigateToStatistics;
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
    this.user,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // Daily inspiring messages
  final List<String> _dailyMessages = [
    '🤲 Thank you. Today as well, your subscription helps support a family in need.',
    '🌙 Every verse you read brings light to your heart and hope to others.',
    '💚 Your daily habit is a gift to your soul and a blessing to those around you.',
    '🌟 With each ayah, you grow closer to Allah and inspire others to do the same.',
    '🕌 Your commitment to the Quran is a legacy for generations to come.',
    '📖 Reading the Quran is not just an act of worship, but a conversation with the Divine.',
    '✨ Every letter you recite is a light that illuminates your path.',
    '🤝 Your subscription helps provide free access to the Quran for those who cannot afford it.',
  ];

  String _getDailyMessage() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return _dailyMessages[dayOfYear % _dailyMessages.length];
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 80;
      if (scrolled != _isScrolled) {
        setState(() => _isScrolled = scrolled);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getTodayDate() {
    final now = DateTime.now();
    final weekdays = [
      AppTranslations.getText(widget.currentLanguage, 'monday'),
      AppTranslations.getText(widget.currentLanguage, 'tuesday'),
      AppTranslations.getText(widget.currentLanguage, 'wednesday'),
      AppTranslations.getText(widget.currentLanguage, 'thursday'),
      AppTranslations.getText(widget.currentLanguage, 'friday'),
      AppTranslations.getText(widget.currentLanguage, 'saturday'),
      AppTranslations.getText(widget.currentLanguage, 'sunday'),
    ];
    final months = [
      AppTranslations.getText(widget.currentLanguage, 'january'),
      AppTranslations.getText(widget.currentLanguage, 'february'),
      AppTranslations.getText(widget.currentLanguage, 'march'),
      AppTranslations.getText(widget.currentLanguage, 'april'),
      AppTranslations.getText(widget.currentLanguage, 'may'),
      AppTranslations.getText(widget.currentLanguage, 'june'),
      AppTranslations.getText(widget.currentLanguage, 'july'),
      AppTranslations.getText(widget.currentLanguage, 'august'),
      AppTranslations.getText(widget.currentLanguage, 'september'),
      AppTranslations.getText(widget.currentLanguage, 'october'),
      AppTranslations.getText(widget.currentLanguage, 'november'),
      AppTranslations.getText(widget.currentLanguage, 'december'),
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final getText = (String key) =>
        AppTranslations.getText(widget.currentLanguage, key);
    final userName = widget.user?.name ?? 'Guest';
    final dailyMessage = _getDailyMessage();
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : '👤';

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF5F0EB),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ========== SMOOTH SLIVER APP BAR ==========
          SliverAppBar(
            expandedHeight: 170,
            floating: true,
            pinned: true,
            snap: false,
            stretch: false,
            backgroundColor: isDark
                ? const Color(0xFF0A0A0A)
                : const Color(0xFFF5F0EB),
            elevation: _isScrolled ? 4 : 0,
            shadowColor: Colors.black.withValues(alpha: 0.1),

            // ===== TITLE (only shown when scrolled) =====
            title: _isScrolled
                ? Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC9A96E), Color(0xFFE8D5A3)],
                          ),
                          shape: BoxShape.circle,
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
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Salam, $userName',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : null,

            // ===== ACTIONS (shown when scrolled) =====
            actions: _isScrolled
                ? [
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {},
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {},
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ]
                : null,

            // ===== FLEXIBLE SPACE =====
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
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
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Top Row: Profile + Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Profile Avatar with ring
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFC9A96E),
                                    Color(0xFFE8D5A3),
                                  ],
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
                            // Action Buttons
                            Row(
                              children: [
                                // Notification Bell
                                Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
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
                                const SizedBox(width: 12),
                                // Settings Gear
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
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
                        const SizedBox(height: 14),

                        // Greeting
                        Text(
                          '🌙 Salam, $userName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.white.withValues(alpha: 0.6),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getTodayDate(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFC9A96E,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFFC9A96E,
                                  ).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Color(0xFFC9A96E),
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '12 ${getText('ramadan')}',
                                    style: const TextStyle(
                                      color: Color(0xFFC9A96E),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ========== MAIN CONTENT ==========
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ========== 📖 VERSE OF THE DAY ==========
                _buildVerseOfTheDay(isDark, getText),

                const SizedBox(height: 20),

                // ========== 🤲 INSPIRING DAILY MESSAGE ==========
                _buildDailyInspiration(isDark, dailyMessage),

                const SizedBox(height: 20),

                // ========== QUICK ACTIONS GRID ==========
                _buildQuickActionsGrid(isDark, getText),

                const SizedBox(height: 20),

                // ========== READING PROGRESS ==========
                _buildReadingProgress(isDark, getText),

                const SizedBox(height: 20),

                // ========== FEATURED SURAHS ==========
                _buildFeaturedSurahs(isDark, getText),

                const SizedBox(height: 20),

                // ========== RECENT ACTIVITY ==========
                _buildRecentActivity(isDark, getText),

                const SizedBox(height: 20),

                // ========== 🌐 WEBSITE LINK ==========
                _buildWebsiteLink(isDark, getText),

                const SizedBox(height: 30),
              ]),
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
                      '📖 Verse of the Day',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sourate Al-Insān · verse 8',
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
                  child: const Text(
                    'Today',
                    style: TextStyle(
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
                        'Translation',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '« Et ils offrent la nourriture, malgré son amour, au pauvre, à l\'orphelin et au captif. »',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getText('translation'),
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
  Widget _buildDailyInspiration(bool isDark, String message) {
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
                  '💚 Daily Inspiration',
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
        'tap': () {},
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
        'label': getText('statistics'),
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

  // ========== READING PROGRESS ==========
  Widget _buildReadingProgress(bool isDark, String Function(String) getText) {
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
                      '35% ${getText('completed')}',
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
                  '35%',
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
              value: 0.35,
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
              _buildProgressStat('📖', '8 Surahs', isDark),
              _buildProgressStat('📜', '247 Verses', isDark),
              _buildProgressStat('🔥', '12 Day Streak', isDark),
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
  Widget _buildFeaturedSurahs(bool isDark, String Function(String) getText) {
    final surahs = [
      {'name': 'Al-Fatihah', 'verses': 7, 'icon': '🌟'},
      {'name': 'Al-Baqarah', 'verses': 286, 'icon': '📖'},
      {'name': 'Al-Imran', 'verses': 200, 'icon': '🕌'},
      {'name': 'Al-Kahf', 'verses': 110, 'icon': '💫'},
    ];

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📚 Featured Surahs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: const Color(0xFF1A5F4A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...surahs.map(
            (surah) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFF8F5F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      surah['icon'] as String,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            surah['name'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            '${surah['verses']} verses',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A5F4A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Read',
                        style: TextStyle(
                          color: Color(0xFF1A5F4A),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== RECENT ACTIVITY ==========
  Widget _buildRecentActivity(bool isDark, String Function(String) getText) {
    final activities = [
      {'title': 'Read Al-Fatihah', 'subtitle': 'Today, 10:30 AM', 'icon': '📖'},
      {
        'title': 'Completed Al-Baqarah',
        'subtitle': 'Yesterday, 9:00 PM',
        'icon': '✅',
      },
      {'title': 'Started Al-Imran', 'subtitle': '2 days ago', 'icon': '🚀'},
    ];

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
            '⏰ Recent Activity',
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
        ],
      ),
    );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🌐 Website coming soon!',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              duration: const Duration(seconds: 2),
            ),
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
                    '🌐 Visit Our Website',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'Coming soon - Stay tuned for updates!',
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
