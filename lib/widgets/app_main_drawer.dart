import 'package:flutter/material.dart';
import 'package:qrn_app/navigation/app_navigation.dart';
import 'package:qrn_app/navigation/app_shell_scope.dart';
import 'package:qrn_app/theme/app_surfaces.dart';
import 'package:qrn_app/translations.dart';

class AppMainDrawer extends StatelessWidget {
  const AppMainDrawer({super.key});

  static const _primary = Color(0xFF1A5F4A);
  static const _primaryLight = Color(0xFF2D7A62);

  @override
  Widget build(BuildContext context) {
    final scope = AppShellScope.of(context);
    final getText = (String key) =>
        Translations.getText(scope.currentLanguage, key);
    final userName = scope.user?.name ?? 'Guest';

    void goTab(int index) {
      Navigator.pop(context);
      scope.onSelectTab(index);
    }

    return AppSurfaces.themedDrawer(
      isDark: scope.isDarkMode,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primary, _primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getText('appTitleShort'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${getText('salam')}, $userName',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _tile(
            context,
            icon: Icons.home_rounded,
            label: getText('home'),
            selected: scope.selectedTab == 0,
            onTap: () => goTab(0),
          ),
          _tile(
            context,
            icon: Icons.menu_book_rounded,
            label: getText('quran'),
            selected: scope.selectedTab == 1,
            onTap: () => goTab(1),
          ),
          _tile(
            context,
            icon: Icons.access_time_rounded,
            label: getText('moreCardPrayerTimes'),
            selected: scope.selectedTab == 2,
            onTap: () => goTab(2),
          ),
          _tile(
            context,
            icon: Icons.apps_rounded,
            label: getText('more'),
            selected: scope.selectedTab == 3,
            onTap: () => goTab(3),
          ),
          _tile(
            context,
            icon: Icons.settings_outlined,
            label: getText('settings'),
            selected: scope.selectedTab == 4,
            onTap: () => goTab(4),
          ),
          const Divider(height: 1),
          _tile(
            context,
            icon: Icons.explore_rounded,
            label: getText('moreCardQibla'),
            onTap: () {
              Navigator.pop(context);
              scope.onQibla();
            },
          ),
          _tile(
            context,
            icon: Icons.volunteer_activism_rounded,
            label: getText('moreCardDuas'),
            onTap: () {
              Navigator.pop(context);
              scope.onDuas();
            },
          ),
          _tile(
            context,
            icon: Icons.headphones_rounded,
            label: getText('moreCardQuranAudio'),
            onTap: () {
              Navigator.pop(context);
              scope.onQuranAudio();
            },
          ),
          _tile(
            context,
            icon: Icons.mosque_outlined,
            label: getText('moreCardHowToPray'),
            onTap: () {
              Navigator.pop(context);
              scope.onHowToPray();
            },
          ),
          const Divider(height: 1),
          _tile(
            context,
            icon: Icons.notifications_active_outlined,
            label: getText('notificationsTitle'),
            onTap: () {
              Navigator.pop(context);
              openAppNotifications(context);
            },
          ),
          _tile(
            context,
            icon: Icons.info_outline_rounded,
            label: getText('aboutUs'),
            onTap: () {
              Navigator.pop(context);
              openAboutUs(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: selected ? _primary : _primary),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: selected,
      selectedTileColor: _primary.withValues(alpha: 0.08),
      onTap: onTap,
    );
  }
}
