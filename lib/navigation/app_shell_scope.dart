import 'package:flutter/material.dart';
import 'package:qrn_app/auth_service.dart';

/// Navigation + theme context for main tabs (Home, Quran, Prayer, More, Settings).
class AppShellScope extends InheritedWidget {
  final int selectedTab;
  final ValueChanged<int> onSelectTab;
  final bool isDarkMode;
  final String currentLanguage;
  final User? user;
  final VoidCallback onQibla;
  final VoidCallback onDuas;
  final VoidCallback onQuranAudio;
  final VoidCallback onHowToPray;

  const AppShellScope({
    super.key,
    required this.selectedTab,
    required this.onSelectTab,
    required this.isDarkMode,
    required this.currentLanguage,
    required this.user,
    required this.onQibla,
    required this.onDuas,
    required this.onQuranAudio,
    required this.onHowToPray,
    required super.child,
  });

  static AppShellScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppShellScope>();
    assert(scope != null, 'AppShellScope not found');
    return scope!;
  }

  static AppShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppShellScope>();
  }

  @override
  bool updateShouldNotify(AppShellScope oldWidget) {
    return selectedTab != oldWidget.selectedTab ||
        isDarkMode != oldWidget.isDarkMode ||
        currentLanguage != oldWidget.currentLanguage ||
        user != oldWidget.user;
  }
}
