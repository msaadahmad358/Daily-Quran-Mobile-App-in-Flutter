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

// ============ TRANSLATIONS ============
class AppTranslations {
  static const Map<String, Map<String, String>> _translations = {
    'English': {
      'appTitle': 'Daily Quran', // ← CHANGED
      'yourDaily': 'YOUR DAILY',
      'quranHabit': 'QURAN HABIT',
      'today': 'Today',
      'todayDate': 'Today',
      'translation':
          'Translation Muhammad Hamidullah, éd. révisée 2021 — licence vérifiée',
      'tafsir':
          'Tafsir — The verse describes those who give while desiring what they share. Ibn Kathīr emphasizes that the value lies in this behavior, not the amount of effort.',
      'readQuran': 'Read Quran',
      'prayerTimes': 'Prayer Times',
      'history': 'History',
      'readingProgress': 'Reading Progress',
      'completed': 'completed',
      'quran': 'Quran',
      'dua': 'Dua & Supplications',
      'settings': 'Settings',
      'language': 'Language',
      'darkMode': 'Dark Mode',
      'lightMode': 'Light Mode',
      'switchToLight': 'Switch to light theme',
      'switchToDark': 'Switch to dark theme',
      'notifications': 'Notifications',
      'quranTranslation': 'Quran Translation',
      'audioRecitation': 'Audio Recitation',
      'about': 'About',
      'version': 'Version',
      'verses': 'verses',
      'todayVerse': 'Sourate Al-Insān · verse 8',
      'duaForFasting': 'Dua for Fasting',
      'duaForBreaking': 'Dua for Breaking Fast',
      'duaLaylatulQadr': 'Dua for Laylatul Qadr',
      'duaForGuidance': 'Dua for Guidance',
      'ramadan': 'RAMADAN',
      'surahName': 'Al-Insān',
      'getStarted': 'Get Started',
      'skip': 'Skip',
      'next': 'Next',
      'welcome': 'Welcome to Daily Quran', // ← CHANGED
      'welcomeDesc':
          'Read, learn, and understand the Quran with daily verses and translations.',
      'onboarding1': 'Daily Quran Verses',
      'onboarding1Desc':
          'Start your day with a verse from the Quran with translation and Tafsir.',
      'onboarding2': 'Track Your Progress',
      'onboarding2Desc':
          'Monitor your reading progress and stay consistent with your Quran habit.',
      'onboarding3': 'Prayer Times & Dua',
      'onboarding3Desc':
          'Never miss a prayer and find authentic duas for every occasion.',
      'login': 'Login',
      'signup': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'forgotPassword': 'Forgot Password?',
      'dontHaveAccount': 'Don\'t have an account?',
      'alreadyHaveAccount': 'Already have an account?',
      'orContinueWith': 'Or continue with',
      'google': 'Google',
      'apple': 'Apple',
      'loginSuccess': 'Login Successful',
      'signupSuccess': 'Account Created',
      'surah': 'Surah',
      'ayah': 'Ayah',
      'january': 'January',
      'february': 'February',
      'march': 'March',
      'april': 'April',
      'may': 'May',
      'june': 'June',
      'july': 'July',
      'august': 'August',
      'september': 'September',
      'october': 'October',
      'november': 'November',
      'december': 'December',
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
      'subscription': 'Subscription',
      'donate': 'Donate',
      'qibla': 'Qibla Compass',
      'subscribe': 'Subscribe',
      'monthly': 'Monthly',
      'yearly': 'Yearly',
      'perMonth': '/mo',
      'perYear': '/yr',
      'freeTrial': 'Free Trial',
      'cancelAnytime': 'Cancel anytime',
      'donation': 'Donation',
      'oneTime': 'One Time',
      'recurring': 'Recurring',
      'customAmount': 'Custom Amount',
      'donateNow': 'Donate Now',
      'thankYou': 'Thank You for Your Support!',
      'qiblaDirection': 'Qibla Direction',
      'pointToQibla': 'Point your device towards Qibla',
      'north': 'N',
      'south': 'S',
      'east': 'E',
      'west': 'W',
      'support': 'Support & Donation',
    },
    'French': {
      'appTitle': 'Coran Quotidien', // ← CHANGED
      'yourDaily': 'VOTRE QUOTIDIEN',
      'quranHabit': 'HABITUDE DU CORAN',
      'today': 'Aujourd\'hui',
      'todayDate': 'Aujourd\'hui',
      'translation':
          'Traduction Muhammad Hamidullah, éd. révisée 2021 — licence vérifiée',
      'tafsir':
          'TAFSIR — APERÇU — Le verset décrit ceux qui donnent alors qu\'ils désirent eux-mêmes ce qu\'ils partagent. Ibn Kathīr souligne que la valeur du geste tient à ce comportement, non à la quantité d\'effort.',
      'readQuran': 'Lire le Coran',
      'prayerTimes': 'Heures de prière',
      'history': 'Historique',
      'readingProgress': 'Progression de lecture',
      'completed': 'terminé',
      'quran': 'Coran',
      'dua': 'Dou\'a & Supplications',
      'settings': 'Paramètres',
      'language': 'Langue',
      'darkMode': 'Mode sombre',
      'lightMode': 'Mode clair',
      'switchToLight': 'Passer au thème clair',
      'switchToDark': 'Passer au thème sombre',
      'notifications': 'Notifications',
      'quranTranslation': 'Traduction du Coran',
      'audioRecitation': 'Récitation audio',
      'about': 'À propos',
      'version': 'Version',
      'verses': 'versets',
      'todayVerse': 'Sourate Al-Insān · verset 8',
      'duaForFasting': 'Dou\'a pour le jeûne',
      'duaForBreaking': 'Dou\'a pour la rupture du jeûne',
      'duaLaylatulQadr': 'Dou\'a pour Laylatul Qadr',
      'duaForGuidance': 'Dou\'a pour la guidance',
      'ramadan': 'RAMADAN',
      'surahName': 'Al-Insān',
      'getStarted': 'Commencer',
      'skip': 'Passer',
      'next': 'Suivant',
      'welcome': 'Bienvenue sur Coran Quotidien', // ← CHANGED
      'welcomeDesc':
          'Lisez, apprenez et comprenez le Coran avec des versets quotidiens et des traductions.',
      'onboarding1': 'Versets quotidiens du Coran',
      'onboarding1Desc':
          'Commencez votre journée avec un verset du Coran avec traduction et Tafsir.',
      'onboarding2': 'Suivez votre progression',
      'onboarding2Desc':
          'Surveillez votre progression de lecture et restez constant dans votre habitude du Coran.',
      'onboarding3': 'Heures de prière & Dou\'a',
      'onboarding3Desc':
          'Ne manquez jamais une prière et trouvez des dou\'as authentiques pour chaque occasion.',
      'login': 'Se connecter',
      'signup': 'S\'inscrire',
      'email': 'E-mail',
      'password': 'Mot de passe',
      'confirmPassword': 'Confirmer le mot de passe',
      'forgotPassword': 'Mot de passe oublié?',
      'dontHaveAccount': 'Vous n\'avez pas de compte?',
      'alreadyHaveAccount': 'Vous avez déjà un compte?',
      'orContinueWith': 'Ou continuer avec',
      'google': 'Google',
      'apple': 'Apple',
      'loginSuccess': 'Connexion réussie',
      'signupSuccess': 'Compte créé',
      'surah': 'Sourate',
      'ayah': 'Verset',
      'january': 'Janvier',
      'february': 'Février',
      'march': 'Mars',
      'april': 'Avril',
      'may': 'Mai',
      'june': 'Juin',
      'july': 'Juillet',
      'august': 'Août',
      'september': 'Septembre',
      'october': 'Octobre',
      'november': 'Novembre',
      'december': 'Décembre',
      'monday': 'Lundi',
      'tuesday': 'Mardi',
      'wednesday': 'Mercredi',
      'thursday': 'Jeudi',
      'friday': 'Vendredi',
      'saturday': 'Samedi',
      'sunday': 'Dimanche',
      'subscription': 'Abonnement',
      'donate': 'Faire un don',
      'qibla': 'Boussole Qibla',
      'subscribe': 'S\'abonner',
      'monthly': 'Mensuel',
      'yearly': 'Annuel',
      'perMonth': '/mois',
      'perYear': '/an',
      'freeTrial': 'Essai gratuit',
      'cancelAnytime': 'Annulez à tout moment',
      'donation': 'Don',
      'oneTime': 'Unique',
      'recurring': 'Récurrent',
      'customAmount': 'Montant personnalisé',
      'donateNow': 'Faire un don maintenant',
      'thankYou': 'Merci pour votre soutien!',
      'qiblaDirection': 'Direction de la Qibla',
      'pointToQibla': 'Orientez votre appareil vers la Qibla',
      'north': 'N',
      'south': 'S',
      'east': 'E',
      'west': 'O',
      'support': 'Soutien & Don',
    },
  };

  static String getText(String language, String key) {
    return _translations[language]?[key] ??
        _translations['English']?[key] ??
        key;
  }
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
    if (mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
        if (isLoggedIn) {
          _showOnboarding = false;
          _showSplash = false;
        }
      });
    }
  }

  Future<void> _initStatsTracker() async {
    final tracker = ReadingTracker();
    await tracker.initAndSync();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppTranslations.getText(_currentLanguage, 'appTitle'),
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
                ? HomeScreen(
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
                    onLogin: () => setState(() => _isLoggedIn = true),
                    onSignup: () => setState(() => _isLoggedIn = true),
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
