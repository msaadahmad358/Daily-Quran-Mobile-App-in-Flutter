import 'package:flutter/material.dart';
import 'package:qrn_app/about/about_us_screen.dart';
import 'package:qrn_app/navigation/app_shell_scope.dart';
import 'package:qrn_app/notifications_screen.dart';

void openAppNotifications(BuildContext context) {
  final scope = AppShellScope.maybeOf(context);
  final isDark = scope?.isDarkMode ?? false;
  final lang = scope?.currentLanguage ?? 'French';
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => NotificationsScreen(
        isDarkMode: isDark,
        currentLanguage: lang,
      ),
    ),
  );
}

void openAboutUs(BuildContext context) {
  final scope = AppShellScope.maybeOf(context);
  final isDark = scope?.isDarkMode ?? false;
  final lang = scope?.currentLanguage ?? 'French';
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AboutUsScreen(
        isDarkMode: isDark,
        currentLanguage: lang,
      ),
    ),
  );
}
