import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'translations.dart';
import 'base_screen.dart';
import 'auth_service.dart';
import 'login_screen.dart';
// ============================================================
// MODELS
// ============================================================

class AyahReadEvent {
  final String id;
  final String surahName;
  final int surahNumber;
  final int ayahNumber;
  final String ayahText;
  final DateTime timestamp;
  final int durationSeconds;

  AyahReadEvent({
    required this.id,
    required this.surahName,
    required this.surahNumber,
    required this.ayahNumber,
    required this.ayahText,
    required this.timestamp,
    required this.durationSeconds,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'surah_name': surahName,
    'surah_number': surahNumber,
    'ayah_number': ayahNumber,
    'ayah_text': ayahText,
    'timestamp': timestamp.toIso8601String(),
    'duration_seconds': durationSeconds,
  };

  factory AyahReadEvent.fromJson(Map<String, dynamic> json) => AyahReadEvent(
    id: json['id'],
    surahName: json['surah_name'],
    surahNumber: json['surah_number'],
    ayahNumber: json['ayah_number'],
    ayahText: json['ayah_text'],
    timestamp: DateTime.parse(json['timestamp']),
    durationSeconds: json['duration_seconds'],
  );
}

class ReadingSession {
  final String id;
  final String surahName;
  final int surahNumber;
  final DateTime startTime;
  final DateTime endTime;
  final int totalAyahsRead;
  final int durationSeconds;
  final List<int> ayahNumbers;

  ReadingSession({
    required this.id,
    required this.surahName,
    required this.surahNumber,
    required this.startTime,
    required this.endTime,
    required this.totalAyahsRead,
    required this.durationSeconds,
    required this.ayahNumbers,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'surah_name': surahName,
    'surah_number': surahNumber,
    'start_time': startTime.toIso8601String(),
    'end_time': endTime.toIso8601String(),
    'total_ayahs': totalAyahsRead,
    'duration_seconds': durationSeconds,
    'ayah_numbers': ayahNumbers,
  };

  factory ReadingSession.fromJson(Map<String, dynamic> json) => ReadingSession(
    id: json['id'],
    surahName: json['surah_name'],
    surahNumber: json['surah_number'],
    startTime: DateTime.parse(json['start_time']),
    endTime: DateTime.parse(json['end_time']),
    totalAyahsRead: json['total_ayahs'],
    durationSeconds: json['duration_seconds'],
    ayahNumbers: List<int>.from(json['ayah_numbers']),
  );

  String get formattedDuration {
    final hours = (durationSeconds / 3600).floor();
    final minutes = ((durationSeconds % 3600) / 60).floor();
    final seconds = durationSeconds % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }
}

class ReadingSummary {
  final int totalVerses;
  final int totalSessions;
  final int totalTimeSeconds;
  final int currentStreak;
  final int todayVerses;
  final int todayTimeSeconds;
  final int surahsCompleted;
  final double quranProgress;
  final Map<String, int> surahFrequency;
  final List<DailyActivity> weeklyActivity;
  final DateTime lastReadDate;
  final String lastReadSurah;
  final Map<int, int> hourlyDistribution;
  final Map<String, int> monthlyProgress;

  ReadingSummary({
    required this.totalVerses,
    required this.totalSessions,
    required this.totalTimeSeconds,
    required this.currentStreak,
    required this.todayVerses,
    required this.todayTimeSeconds,
    required this.surahsCompleted,
    required this.quranProgress,
    required this.surahFrequency,
    required this.weeklyActivity,
    required this.lastReadDate,
    required this.lastReadSurah,
    required this.hourlyDistribution,
    required this.monthlyProgress,
  });

  String get totalTimeFormatted {
    final hours = (totalTimeSeconds / 3600).floor();
    final minutes = ((totalTimeSeconds % 3600) / 60).floor();
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  String get todayTimeFormatted {
    final minutes = (todayTimeSeconds / 60).floor();
    return '${minutes}m';
  }

  List<MapEntry<String, int>> get topSurahs {
    final entries = surahFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).toList();
  }
}

class DailyActivity {
  final String label;
  final int count;
  final bool isToday;

  DailyActivity({
    required this.label,
    required this.count,
    this.isToday = false,
  });
}

// ============================================================
// READING TRACKER SERVICE - UPDATED
// ============================================================

class ReadingTracker {
  static final ReadingTracker _instance = ReadingTracker._internal();
  factory ReadingTracker() => _instance;
  ReadingTracker._internal();

  static const String _sessionsKey = 'reading_sessions';
  static const String _ayahsKey = 'reading_ayahs';
  static const String _lastSyncKey = 'last_sync';
  static const String _totalVersesKey = 'total_verses_read';
  static const String _streakKey = 'streak_count';

  List<ReadingSession> _sessions = [];
  List<AyahReadEvent> _ayahEvents = [];
  ReadingSummary? _cachedSummary;
  bool _isLoaded = false;
  int _totalVerses = 0;
  int _currentStreak = 0;

  Future<void> initialize() async {
    if (_isLoaded) return;
    await load();
    _isLoaded = true;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Load total verses
    _totalVerses = prefs.getInt(_totalVersesKey) ?? 0;
    _currentStreak = prefs.getInt(_streakKey) ?? 0;

    final sessionsJson = prefs.getString(_sessionsKey);
    if (sessionsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(sessionsJson);
        _sessions = decoded.map((e) => ReadingSession.fromJson(e)).toList();
      } catch (e) {
        _sessions = [];
      }
    }

    final ayahsJson = prefs.getString(_ayahsKey);
    if (ayahsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(ayahsJson);
        _ayahEvents = decoded.map((e) => AyahReadEvent.fromJson(e)).toList();
        _totalVerses = _ayahEvents.length;
        await prefs.setInt(_totalVersesKey, _totalVerses);
      } catch (e) {
        _ayahEvents = [];
      }
    }

    // Recalculate streak
    _currentStreak = _calculateStreak();
    await prefs.setInt(_streakKey, _currentStreak);

    _cachedSummary = _buildSummary();
  }

  Future<void> trackAyah({
    required String surahName,
    required int surahNumber,
    required int ayahNumber,
    required String ayahText,
    required int durationSeconds,
  }) async {
    final now = DateTime.now();

    final event = AyahReadEvent(
      id: '${now.millisecondsSinceEpoch}_${surahNumber}_$ayahNumber',
      surahName: surahName,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      ayahText: ayahText.length > 100
          ? '${ayahText.substring(0, 100)}...'
          : ayahText,
      timestamp: now,
      durationSeconds: durationSeconds.clamp(1, 300),
    );

    // Check if this ayah was already read today to avoid duplicates
    final today = DateTime(now.year, now.month, now.day);
    bool alreadyReadToday = false;
    for (final e in _ayahEvents) {
      final eventDate = DateTime(
        e.timestamp.year,
        e.timestamp.month,
        e.timestamp.day,
      );
      if (eventDate == today &&
          e.surahNumber == surahNumber &&
          e.ayahNumber == ayahNumber) {
        alreadyReadToday = true;
        break;
      }
    }

    if (!alreadyReadToday) {
      _ayahEvents.add(event);
      _totalVerses = _ayahEvents.length;

      // Update streak
      _currentStreak = _calculateStreak();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_totalVersesKey, _totalVerses);
      await prefs.setInt(_streakKey, _currentStreak);
    }

    if (_ayahEvents.length > 5000) _ayahEvents.removeAt(0);

    _cachedSummary = _buildSummary();
    await _save();

    // Auto-sync after tracking
    await autoSync();
  }

  Future<void> trackSession({
    required String surahName,
    required int surahNumber,
    required int startAyah,
    required int endAyah,
    required int totalAyahsRead,
    required int durationSeconds,
    required List<int> ayahNumbers,
  }) async {
    final now = DateTime.now();

    final session = ReadingSession(
      id: 'session_${now.millisecondsSinceEpoch}',
      surahName: surahName,
      surahNumber: surahNumber,
      startTime: now.subtract(Duration(seconds: durationSeconds)),
      endTime: now,
      totalAyahsRead: totalAyahsRead,
      durationSeconds: durationSeconds,
      ayahNumbers: ayahNumbers,
    );

    _sessions.add(session);
    if (_sessions.length > 500) _sessions.removeAt(0);

    _cachedSummary = _buildSummary();
    await _save();

    // Auto-sync after session
    await autoSync();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _sessionsKey,
      jsonEncode(_sessions.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      _ayahsKey,
      jsonEncode(_ayahEvents.map((e) => e.toJson()).toList()),
    );
    await prefs.setInt(_totalVersesKey, _totalVerses);
    await prefs.setInt(_streakKey, _currentStreak);
  }

  Future<void> save() async => await _save();

  // ============ SYNC WITH BACKEND ============

  Future<Map<String, dynamic>> syncWithBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final summary = getSummary();
      final history = getRecentSessions(limit: 50);

      final data = {
        'action': 'sync',
        'total_verses': summary.totalVerses,
        'total_sessions': summary.totalSessions,
        'total_time_seconds': summary.totalTimeSeconds,
        'current_streak': summary.currentStreak,
        'today_verses': summary.todayVerses,
        'today_time_seconds': summary.todayTimeSeconds,
        'surahs_completed': summary.surahsCompleted,
        'quran_progress': summary.quranProgress,
        'last_read_date': summary.lastReadDate.toIso8601String(),
        'last_read_surah': summary.lastReadSurah,
        'history': _ayahEvents
            .map(
              (e) => {
                'surah_name': e.surahName,
                'surah_number': e.surahNumber,
                'ayah_number': e.ayahNumber,
                'ayah_text': e.ayahText,
                'duration_seconds': e.durationSeconds,
                'read_at': e.timestamp.toIso8601String(),
              },
            )
            .toList(),
        'sessions': _sessions
            .map(
              (s) => {
                'surah_name': s.surahName,
                'surah_number': s.surahNumber,
                'start_ayah': s.ayahNumbers.isNotEmpty
                    ? s.ayahNumbers.first
                    : 0,
                'end_ayah': s.ayahNumbers.isNotEmpty ? s.ayahNumbers.last : 0,
                'total_ayahs': s.totalAyahsRead,
                'duration_seconds': s.durationSeconds,
                'start_time': s.startTime.toIso8601String(),
                'end_time': s.endTime.toIso8601String(),
              },
            )
            .toList(),
      };

      final response = await http.post(
        Uri.parse('https://sunnahsource.org/QRN/api/stats.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        },
        body: data,
      );

      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Sync failed: $e'};
    }
  }

  Future<void> autoSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final lastSync = prefs.getString(_lastSyncKey);

      if (lastSync != null) {
        final lastSyncTime = DateTime.parse(lastSync);
        final diff = DateTime.now().difference(lastSyncTime);
        if (diff.inMinutes < 5) return;
      }

      await syncWithBackend();
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> initAndSync() async {
    await initialize();
    await autoSync();
  }

  int _calculateStreak() {
    if (_ayahEvents.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final days = <String>{};
    for (final event in _ayahEvents) {
      final date = DateTime(
        event.timestamp.year,
        event.timestamp.month,
        event.timestamp.day,
      );
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      days.add(key);
    }

    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      if (days.contains(key)) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  int _calculateCompletedSurahs() {
    final surahAyahs = <int, Set<int>>{};
    for (final event in _ayahEvents) {
      surahAyahs.putIfAbsent(event.surahNumber, () => {}).add(event.ayahNumber);
    }

    int completed = 0;
    for (final entry in surahAyahs.entries) {
      if (entry.value.length >= 10) completed++;
    }
    return completed;
  }

  List<DailyActivity> _buildWeeklyActivity() {
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final counts = <String, int>{};

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final dayIndex = date.weekday - 1;

      int count = 0;
      for (final event in _ayahEvents) {
        final eventDate = DateTime(
          event.timestamp.year,
          event.timestamp.month,
          event.timestamp.day,
        );
        final eventKey =
            '${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}';
        if (eventKey == key) count++;
      }
      counts[weekdays[dayIndex]] = count;
    }

    final todayWeekday = now.weekday - 1;
    return weekdays.map((label) {
      final index = weekdays.indexOf(label);
      return DailyActivity(
        label: label,
        count: counts[label] ?? 0,
        isToday: index == todayWeekday,
      );
    }).toList();
  }

  Map<int, int> _buildHourlyDistribution() {
    final distribution = <int, int>{};
    for (int i = 0; i < 24; i++) distribution[i] = 0;

    for (final event in _ayahEvents) {
      final hour = event.timestamp.hour;
      distribution[hour] = (distribution[hour] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, int> _buildMonthlyProgress() {
    final progress = <String, int>{};
    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      int count = 0;
      for (final event in _ayahEvents) {
        final eventDate = DateTime(event.timestamp.year, event.timestamp.month);
        final eventKey =
            '${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}';
        if (eventKey == key) count++;
      }
      progress[key] = count;
    }
    return progress;
  }

  ReadingSummary _buildSummary() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Use stored total verses
    final totalVerses = _ayahEvents.length;

    final totalSessions = _sessions.length;

    int totalTime = 0;
    for (final event in _ayahEvents) {
      totalTime += event.durationSeconds;
    }

    int todayVerses = 0;
    int todayTime = 0;
    for (final event in _ayahEvents) {
      final eventDate = DateTime(
        event.timestamp.year,
        event.timestamp.month,
        event.timestamp.day,
      );
      if (eventDate == today) {
        todayVerses++;
        todayTime += event.durationSeconds;
      }
    }

    int streak = _currentStreak;
    int surahsCompleted = _calculateCompletedSurahs();
    final quranProgress = (totalVerses / 6236 * 100).clamp(0, 100);

    final surahFrequency = <String, int>{};
    for (final event in _ayahEvents) {
      surahFrequency[event.surahName] =
          (surahFrequency[event.surahName] ?? 0) + 1;
    }

    final weeklyActivity = _buildWeeklyActivity();
    final hourlyDistribution = _buildHourlyDistribution();
    final monthlyProgress = _buildMonthlyProgress();

    DateTime lastReadDate = DateTime.now();
    String lastReadSurah = '';
    if (_ayahEvents.isNotEmpty) {
      final lastEvent = _ayahEvents.last;
      lastReadDate = lastEvent.timestamp;
      lastReadSurah = lastEvent.surahName;
    }

    return ReadingSummary(
      totalVerses: totalVerses,
      totalSessions: totalSessions,
      totalTimeSeconds: totalTime,
      currentStreak: streak,
      todayVerses: todayVerses,
      todayTimeSeconds: todayTime,
      surahsCompleted: surahsCompleted,
      quranProgress: quranProgress.toDouble(),
      surahFrequency: surahFrequency,
      weeklyActivity: weeklyActivity,
      lastReadDate: lastReadDate,
      lastReadSurah: lastReadSurah,
      hourlyDistribution: hourlyDistribution,
      monthlyProgress: monthlyProgress,
    );
  }

  ReadingSummary getSummary() {
    if (_cachedSummary == null) _cachedSummary = _buildSummary();
    return _cachedSummary!;
  }

  List<ReadingSession> getRecentSessions({int limit = 20}) {
    final reversed = List<ReadingSession>.from(_sessions.reversed);
    return reversed.take(limit).toList();
  }

  Future<void> refresh() async {
    await load();
    _cachedSummary = _buildSummary();
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionsKey);
    await prefs.remove(_ayahsKey);
    await prefs.remove(_totalVersesKey);
    await prefs.remove(_streakKey);
    _sessions.clear();
    _ayahEvents.clear();
    _totalVerses = 0;
    _currentStreak = 0;
    _cachedSummary = _buildSummary();
    await _save();
  }

  // ============ DEBUG METHODS ============
  Future<void> addDemoData() async {
    // Add 7 demo verses for testing
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < 7; i++) {
      final event = AyahReadEvent(
        id: 'demo_${now.millisecondsSinceEpoch}_$i',
        surahName: 'Al-Fatihah',
        surahNumber: 1,
        ayahNumber: i + 1,
        ayahText: 'Demo ayah text $i',
        timestamp: today.add(Duration(hours: i)),
        durationSeconds: 10 + i * 2,
      );
      _ayahEvents.add(event);
    }

    _totalVerses = _ayahEvents.length;
    _currentStreak = _calculateStreak();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_totalVersesKey, _totalVerses);
    await prefs.setInt(_streakKey, _currentStreak);

    await _save();
    _cachedSummary = _buildSummary();
  }
}

// ============================================================
// STATS SCREEN - UI (Keep existing)
// ============================================================

class StatsScreen extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;

  const StatsScreen({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
  });

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends BaseScreenState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReadingTracker _tracker = ReadingTracker();
  final AuthService _auth = AuthService();
  ReadingSummary? _summary;
  bool _isLoading = true;
  bool _isClearing = false;
  bool _isLoggedIn = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _auth.isLoggedIn();
    final user = await _auth.getCurrentUser();
    setState(() {
      _isLoggedIn = isLoggedIn;
      _currentUser = user;
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _tracker.refresh();
    setState(() {
      _summary = _tracker.getSummary();
      _isLoading = false;
    });
  }

  Future<void> _addDemoData() async {
    await _tracker.addDemoData();
    await _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getText('demoDataAdded')),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your reading history and statistics. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(getText('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(getText('clearAll')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isClearing = true);
      await _tracker.clearAllData();
      await _loadData();
      setState(() => _isClearing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getText('dataCleared')),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final getText = (String key) =>
        Translations.getText(widget.currentLanguage, key);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F2EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A5F4A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        title: Text(
          getText('stats'),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.refresh_rounded),
              onPressed: _isLoading ? null : _loadData,
              tooltip: getText('refreshData'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: _addDemoData,
            tooltip: getText('addDemoData'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFC9A96E),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          tabs: [
            Tab(text: getText('overview')),
            Tab(text: getText('analytics')),
            Tab(text: getText('history')),
          ],
        ),
      ),
      body: _isLoading || _isClearing
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A5F4A)),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(isDark, getText),
                _buildAnalyticsTab(isDark, getText),
                _buildHistoryTab(isDark, getText),
              ],
            ),
    );
  }

  // ============================================================
  // OVERVIEW TAB
  // ============================================================

  Widget _buildOverviewTab(bool isDark, String Function(String) getText) {
    if (_summary == null) return const SizedBox();
    final summary = _summary!;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Create Account Prompt
            if (!_isLoggedIn) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF1A5F4A).withValues(alpha: 0.3),
                            const Color(0xFF2D7A62).withValues(alpha: 0.3),
                          ]
                        : [
                            const Color(0xFF1A5F4A).withValues(alpha: 0.1),
                            const Color(0xFF2D7A62).withValues(alpha: 0.1),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF1A5F4A).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          color: const Color(0xFF1A5F4A),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getText('createAccount'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                getText('createAccountStatsMessage'),
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
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(
                                onLogin: () {
                                  Navigator.of(context).pop();
                                  _checkLoginStatus();
                                },
                                onSignup: () {
                                  Navigator.of(context).pop();
                                  _checkLoginStatus();
                                },
                                onForgotPassword: () {},
                                onSkipLogin: () {
                                  Navigator.of(context).pop();
                                },
                                currentLanguage: widget.currentLanguage,
                                isDarkMode: isDark,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A5F4A),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          getText('signUpNow'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard(
                  icon: Icons.menu_book,
                  label: getText('versesRead'),
                  value: '${summary.totalVerses}',
                  color: const Color(0xFF1A5F4A),
                  isDark: isDark,
                  subtitle: '${summary.todayVerses} ${getText('today')}',
                ),
                _buildStatCard(
                  icon: Icons.local_fire_department,
                  label: getText('readingStreak'),
                  value: '${summary.currentStreak}',
                  color: const Color(0xFFE74C3C),
                  isDark: isDark,
                  subtitle: summary.currentStreak > 0
                      ? '🔥 ${summary.currentStreak} days'
                      : getText('startTodayStat'),
                ),
                _buildStatCard(
                  icon: Icons.timer,
                  label: getText('timeSpent'),
                  value: summary.totalTimeFormatted,
                  color: const Color(0xFFC9A96E),
                  isDark: isDark,
                  subtitle: '${summary.todayTimeFormatted} ${getText('today')}',
                ),
                _buildStatCard(
                  icon: Icons.check_circle,
                  label: getText('surahsRead'),
                  value: '${summary.surahsCompleted}',
                  color: const Color(0xFF2E86C1),
                  isDark: isDark,
                  subtitle: '${summary.totalSessions} ${getText('sessions')}',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Progress Overview
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _buildCardDecoration(isDark),
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
                              getText('quranProgress'),
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
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A5F4A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${summary.quranProgress.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Color(0xFF1A5F4A),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (summary.quranProgress / 100).toDouble(),
                      backgroundColor: isDark
                          ? Colors.grey[800]
                          : const Color(0xFFE8E0D8),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF1A5F4A),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Top Surahs
            if (summary.topSurahs.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: _buildCardDecoration(isDark),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getText('mostReadSurahs'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...summary.topSurahs.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.key,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1A5F4A,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${entry.value}',
                                style: const TextStyle(
                                  color: Color(0xFF1A5F4A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
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

            const SizedBox(height: 20),

            // Daily Tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A5F4A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF1A5F4A).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb,
                    color: Color(0xFF1A5F4A),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getDailyTip(),
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Clear Data Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A1A1A)
                    : const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getText('clearAllData'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          getText('clearAllDataDesc'),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isClearing ? null : _clearAllData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: _isClearing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            getText('clear'),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ANALYTICS TAB
  // ============================================================

  Widget _buildAnalyticsTab(bool isDark, String Function(String) getText) {
    if (_summary == null) return const SizedBox();
    final summary = _summary!;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly Heatmap
            _buildSectionHeader(getText('weeklyHeatmap'), isDark),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _buildCardDecoration(isDark),
              child: Column(
                children: [
                  _buildWeeklyHeatmap(summary.weeklyActivity, isDark),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('0', Colors.grey[300]!, isDark),
                      _buildLegendItem('1-2', Colors.green[200]!, isDark),
                      _buildLegendItem('3-5', Colors.green[400]!, isDark),
                      _buildLegendItem('6-10', Colors.green[600]!, isDark),
                      _buildLegendItem('10+', const Color(0xFF1A5F4A), isDark),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Hourly Distribution
            _buildSectionHeader(getText('hourlyDistribution'), isDark),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _buildCardDecoration(isDark),
              child: _buildHourlyDistributionGraph(
                summary.hourlyDistribution,
                isDark,
              ),
            ),

            const SizedBox(height: 20),

            // Monthly Progress
            _buildSectionHeader(getText('monthlyProgress'), isDark),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _buildCardDecoration(isDark),
              child: _buildMonthlyProgressGraph(
                summary.monthlyProgress,
                isDark,
              ),
            ),

            const SizedBox(height: 20),

            // Streak Badge
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1A3A2E), const Color(0xFF0D2B1E)]
                      : [const Color(0xFF1A5F4A), const Color(0xFF0D3B2E)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9A96E).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text('🔥', style: const TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${summary.currentStreak} ${getText('dayStreak')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          summary.currentStreak > 0
                              ? getText('keepGoing')
                              : getText('startToday'),
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // VISUALIZATION WIDGETS
  // ============================================================

  Widget _buildWeeklyHeatmap(List<DailyActivity> data, bool isDark) {
    final maxCount = data.map((d) => d.count).reduce((a, b) => a > b ? a : b);
    final safeMax = maxCount > 0 ? maxCount : 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: data.map((day) {
        final intensity = (day.count / safeMax).clamp(0.0, 1.0);
        final color = day.isToday
            ? const Color(0xFFC9A96E)
            : Color.lerp(
                isDark ? Colors.grey[800] : Colors.grey[200],
                const Color(0xFF1A5F4A),
                intensity,
              )!;

        return Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: day.isToday
                    ? Border.all(color: const Color(0xFFC9A96E), width: 2)
                    : null,
              ),
              child: Center(
                child: day.count > 0
                    ? Text(
                        '${day.count}',
                        style: TextStyle(
                          color: day.isToday
                              ? Colors.white
                              : (intensity > 0.5
                                    ? Colors.white
                                    : Colors.black87),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Icon(
                        Icons.circle,
                        color: isDark ? Colors.grey[600] : Colors.grey[300],
                        size: 6,
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              day.label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHourlyDistributionGraph(Map<int, int> data, bool isDark) {
    final maxVal = data.values.reduce((a, b) => a > b ? a : b);
    final safeMax = maxVal > 0 ? maxVal : 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(24, (hour) {
          final value = data[hour] ?? 0;
          final height = (value / safeMax * 60).clamp(0.0, 60.0);
          final isPeak = value > 0 && value >= (maxVal * 0.8);

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (value > 0)
                  Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 7,
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                    ),
                  ),
                Container(
                  height: height > 0 ? height : 2,
                  width: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: isPeak
                          ? [const Color(0xFF1A5F4A), const Color(0xFFC9A96E)]
                          : [
                              isDark ? Colors.grey[700]! : Colors.grey[300]!,
                              isDark ? Colors.grey[600]! : Colors.grey[400]!,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hour.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 7,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMonthlyProgressGraph(Map<String, int> data, bool isDark) {
    final maxVal = data.values.reduce((a, b) => a > b ? a : b);
    final safeMax = maxVal > 0 ? maxVal : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: data.entries.map((entry) {
            final value = entry.value;
            final height = (value / safeMax * 60).clamp(0.0, 60.0);
            final monthLabel = entry.key.split('-').last;

            return Column(
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 30,
                  height: height > 0 ? height : 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        const Color(0xFF1A5F4A),
                        const Color(0xFF2D7A62),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getMonthName(int.parse(monthLabel)),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // ============================================================
  // HISTORY TAB
  // ============================================================

  Widget _buildHistoryTab(bool isDark, String Function(String) getText) {
    final recentSessions = _tracker.getRecentSessions(limit: 50);

    if (recentSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              getText('noHistory'),
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              getText('startReadingHistory'),
              style: TextStyle(
                color: isDark ? Colors.grey[600] : Colors.grey[500],
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recentSessions.length,
        itemBuilder: (context, index) {
          final session = recentSessions[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: _buildCardDecoration(isDark),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A5F4A), Color(0xFF2D7A62)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.surahName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.menu_book,
                            size: 12,
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${session.totalAyahsRead} ayahs',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.timer,
                            size: 12,
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            session.formattedDuration,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 14),
                      SizedBox(width: 4),
                      Text(
                        getText('read'),
                        style: TextStyle(color: Colors.green, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // UI HELPERS
  // ============================================================

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildCardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  BoxDecoration _buildCardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      borderRadius: BorderRadius.circular(3),
      border: Border(
        left: BorderSide(
          color: const Color(0xFF1A5F4A).withValues(alpha: isDark ? 0.6 : 1),
          width: 4,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  String _getDailyTip() {
    final tips = [
      'Read at least 5 verses daily to build a strong habit.',
      'Consistency is better than quantity. Read daily, even if small.',
      'Try to understand the meaning of what you read, not just recite.',
      'Set a specific time each day for your Quran reading.',
      'Share what you learn with others to deepen your understanding.',
      'Reflect on the verses you read. Apply them to your life.',
      'Start with short surahs and gradually increase your reading.',
      'The best deed is the one done consistently, even if small.',
      'Reading the Quran is a conversation with Allah. Listen carefully.',
      'Make dua before you start reading for understanding and guidance.',
    ];
    final today = DateTime.now().day;
    return tips[today % tips.length];
  }
}
