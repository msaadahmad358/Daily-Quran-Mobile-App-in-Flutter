import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:device_preview/device_preview.dart';
import 'splash_screen.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'subscription_screen.dart';
import 'donation_screen.dart';
import 'qibla_compass_screen.dart';
import 'forgot_password_screen.dart';
import 'stats.dart';
import 'auth_service.dart';
import 'welcome_screen.dart';
import 'translations.dart';

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
void main() {
  runApp(DevicePreview(enabled: false, builder: (context) => const MyApp()));
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
  bool _showOnboarding = true;
  bool _showSplash = true;
  bool _showWelcome = false;
  User? _currentUser;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _initStatsTracker();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  Future<void> _checkAuthStatus() async {
    final auth = AuthService();
    final isLoggedIn = await auth.isLoggedIn();
    final user = await auth.getCurrentUser();

    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
        _currentUser = user;
        if (isLoggedIn) {
          _showOnboarding = false;
          _showSplash = false;
          _showWelcome = true;
        }
      });
    }
  }

  Future<void> _initStatsTracker() async {
    final tracker = ReadingTracker();
    await tracker.initAndSync();
  }

  void _handleLogin() {
    setState(() {
      _isLoggedIn = true;
      _showWelcome = true;
    });
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _showWelcome = false;
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
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
      home: _showSplash
          ? const SplashScreen()
          : _showOnboarding
          ? OnboardingScreen(
              onComplete: () => setState(() => _showOnboarding = false),
              currentLanguage: _currentLanguage,
              isDarkMode: _isDarkMode,
            )
          : (_isLoggedIn
                ? _showWelcome
                      ? WelcomeScreen(
                          onContinue: () =>
                              setState(() => _showWelcome = false),
                          isDarkMode: _isDarkMode,
                          currentLanguage: _currentLanguage,
                          userName: _currentUser?.name ?? 'Guest',
                        )
                      : HomeScreen(
                          onThemeToggle: (value) =>
                              setState(() => _isDarkMode = value),
                          onLanguageChange: (language) =>
                              setState(() => _currentLanguage = language),
                          currentLanguage: _currentLanguage,
                          isDarkMode: _isDarkMode,
                          onNavigateToSubscription: () {
                            navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (context) => SubscriptionScreen(
                                  isDarkMode: _isDarkMode,
                                  currentLanguage: _currentLanguage,
                                ),
                              ),
                            );
                          },
                          onNavigateToDonation: () {
                            navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (context) => DonationScreen(
                                  isDarkMode: _isDarkMode,
                                  currentLanguage: _currentLanguage,
                                ),
                              ),
                            );
                          },
                          onNavigateToQibla: () {
                            navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (context) => QiblaCompassScreen(
                                  isDarkMode: _isDarkMode,
                                  currentLanguage: _currentLanguage,
                                ),
                              ),
                            );
                          },
                        )
                : LoginScreen(
                    onLogin: _handleLogin,
                    onSignup: _handleLogin,
                    onForgotPassword: () {
                      navigatorKey.currentState?.push(
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(
                            isDarkMode: _isDarkMode,
                            currentLanguage: _currentLanguage,
                          ),
                        ),
                      );
                    },
                    currentLanguage: _currentLanguage,
                    isDarkMode: _isDarkMode,
                  )),
    );
  }
}
