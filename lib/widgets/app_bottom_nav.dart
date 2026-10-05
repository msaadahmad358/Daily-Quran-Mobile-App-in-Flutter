import 'package:flutter/material.dart';

/// Bottom tab PNGs (teal/gold) — no green tint in dark mode.
class NavTabIcon extends StatelessWidget {
  final int index;
  final bool selected;
  final bool isDarkMode;

  const NavTabIcon({
    super.key,
    required this.index,
    required this.selected,
    required this.isDarkMode,
  });

  static const assetPaths = [
    'assets/nav/nav_home.png',
    'assets/nav/nav_quran.png',
    'assets/nav/nav_prayer.png',
    'assets/nav/nav_more.png',
    'assets/nav/nav_settings.png',
  ];

  static const _fallbackIcons = [
    Icons.home_rounded,
    Icons.menu_book_rounded,
    Icons.mosque_rounded,
    Icons.apps_rounded,
    Icons.settings_rounded,
  ];

  static void precacheAll(BuildContext context) {
    for (final path in assetPaths) {
      precacheImage(AssetImage(path), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(index >= 0 && index <= 4);
    const size = 25.5;
    const themeGreen = Color(0xFF1A5F4A);

    final fallbackColor = isDarkMode
        ? (selected ? Colors.white : Colors.grey.shade500)
        : themeGreen;

    Widget icon = Image.asset(
      assetPaths[index],
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Nav icon missing: ${assetPaths[index]} → $error');
        return Icon(
          _fallbackIcons[index],
          size: size,
          color: fallbackColor,
        );
      },
    );

    if (!isDarkMode) {
      icon = ColorFiltered(
        colorFilter: const ColorFilter.mode(themeGreen, BlendMode.srcIn),
        child: icon,
      );
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: selected ? 1 : (isDarkMode ? 0.5 : 0.55),
      child: icon,
    );
  }
}

class AppBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool isDarkMode;
  final List<String> labels;

  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.isDarkMode,
    required this.labels,
  });

  static const _primary = Color(0xFF1A5F4A);

  @override
  Widget build(BuildContext context) {
    assert(labels.length >= 5);
    final inactive =
        isDarkMode ? Colors.grey.shade500 : const Color(0xFF8A9690);
    final barColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final activeLabel = isDarkMode ? Colors.white : _primary;
    final indicatorColor = isDarkMode ? Colors.white : _primary;

    return ColoredBox(
      color: barColor,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: List.generate(5, (i) {
                final sel = selectedIndex == i;

                return Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onTap(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 2.5,
                              width: sel ? 27 : 0,
                              margin: const EdgeInsets.only(bottom: 3),
                              decoration: BoxDecoration(
                                color: sel ? indicatorColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            NavTabIcon(
                              index: i,
                              selected: sel,
                              isDarkMode: isDarkMode,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              labels[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight:
                                    sel ? FontWeight.w600 : FontWeight.w500,
                                color: sel ? activeLabel : inactive,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
