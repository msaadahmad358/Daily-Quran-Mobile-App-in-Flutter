import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:device_preview/device_preview.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'more/qibla_page.dart';
import 'stats.dart';
import 'auth_service.dart';
import 'translations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'services/quran_data_service.dart';
import 'package:provider/provider.dart';
import 'services/global_surah_audio_service.dart';
import 'services/app_language_prefs.dart';
import 'services/prayer_notification_service.dart';

// ============ THEME ============
class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1A5F4A),
    scaffoldBackgroundColor: const Color(0xFFF8F5F0),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1A5F4A),
      secondary: Color(0xFFC9A96E),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1A1A1A),
    ),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Color(0xFFF8F5F0),
      foregroundColor: Color(0xFF1A5F4A),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    fontFamily: 'System',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A5F4A),
      ),
      displayMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A5F4A),
      ),
      displaySmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1A5F4A),
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF2D2D2D)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF4A4A4A)),
      bodySmall: TextStyle(fontSize: 12, color: Color(0xFF6B6B6B)),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF2D7A62),
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF2D7A62),
      secondary: Color(0xFFC9A96E),
      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFE8E8E8),
    ),
    cardColor: const Color(0xFF1E1E1E),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Color(0xFF121212),
      foregroundColor: Color(0xFFC9A96E),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    fontFamily: 'System',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFFC9A96E),
      ),
      displayMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Color(0xFFC9A96E),
      ),
      displaySmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Color(0xFFC9A96E),
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFD4D4D4)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFB0B0B0)),
      bodySmall: TextStyle(fontSize: 12, color: Color(0xFF888888)),
    ),
  );
}

// ============ MAIN APP ============
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await QuranDataService.instance.load();
  await PrayerNotificationService.instance.init();
  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => GlobalSurahAudioService(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  String _currentLanguage = 'French';
  bool _isLoggedIn = false;
  bool _showSplash = true;
  bool _bootReady = false;
  User? _currentUser;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final savedLang = await AppLanguagePrefs.get();
    await AppLanguagePrefs.set(savedLang);
    await Future.wait([
      _checkAuthStatus(),
      _initStatsTracker(),
    ]);
    if (mounted) {
      setState(() {
        _currentLanguage = savedLang;
        _bootReady = true;
      });
    }
  }

  Future<void> _checkAuthStatus() async {
    final auth = AuthService();
    final isLoggedIn = await auth.isLoggedIn();
    final user = await auth.getCurrentUser();

    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
        _currentUser = user;
      });
    }
  }

  void _onSplashFinished() {
    if (mounted) setState(() => _showSplash = false);
  }

  Future<void> _initStatsTracker() async {
    final tracker = ReadingTracker();
    await tracker.initAndSync();
  }

  Future<void> _refreshUser() async {
    final auth = AuthService();
    final user = await auth.getCurrentUser();
    if (mounted) {
      setState(() => _currentUser = user);
    }
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Translations.getText(_currentLanguage, 'appTitle'),
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      navigatorKey: navigatorKey,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            // Lock font scaling to 1.0 — ignores device font size settings
            textScaler: const TextScaler.linear(1.0),
            // Optional: also lock by clamping textScaleFactor for older Flutter
            // textScaleFactor: 1.0,
          ),
          child: child!,
        );
      },
      home: _showSplash || !_bootReady
          ? SplashScreen(
              onFinished: _onSplashFinished,
              appTitle: Translations.getText(
                _currentLanguage,
                'appTitleShort',
              ),
              subtitle: Translations.getText(
                _currentLanguage,
                'splashSubtitle',
              ),
            )
          : HomeScreen(
              onThemeToggle: (value) => setState(() => _isDarkMode = value),
              onUserUpdated: _refreshUser,
              onLanguageChange: (language) async {
                setState(() => _currentLanguage = language);
                await AppLanguagePrefs.set(language);
                await PrayerNotificationService.instance.rescheduleFromCache();
              },
              currentLanguage: _currentLanguage,
              isDarkMode: _isDarkMode,
              onNavigateToQibla: () {
                navigatorKey.currentState?.push(
                  MaterialPageRoute(
                    builder: (context) => QiblaPage(
                      isDarkMode: _isDarkMode,
                      currentLanguage: _currentLanguage,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
