import 'package:flutter/material.dart';

/// Shared light/dark surfaces (More, Home, tabs).
class AppSurfaces {
  AppSurfaces._();

  static const darkScaffold = Color(0xFF121212);
  static const lightScaffold = Color(0xFFF5F2EE);
  static const darkCard = Color(0xFF1E1E1E);
  static const lightCard = Colors.white;

  static Color scaffold(bool isDark) =>
      isDark ? darkScaffold : lightScaffold;

  static Color card(bool isDark) => isDark ? darkCard : lightCard;

  static Drawer themedDrawer({
    required bool isDark,
    required Widget child,
  }) {
    return Drawer(
      backgroundColor: isDark ? darkCard : null,
      surfaceTintColor: Colors.transparent,
      child: Theme(
        data: ThemeData(
          brightness: isDark ? Brightness.dark : Brightness.light,
          listTileTheme: ListTileThemeData(
            textColor: isDark ? Colors.white : const Color(0xFF1A2E35),
            iconColor: const Color(0xFF1A5F4A),
          ),
          dividerColor: isDark ? Colors.white12 : Colors.grey.shade300,
        ),
        child: child,
      ),
    );
  }
}
