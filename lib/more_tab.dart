import 'package:flutter/material.dart';
import 'package:qrn_app/more/duas_screen.dart';
import 'package:qrn_app/more/feeling_ayats_screen.dart';
import 'package:qrn_app/more/islamic_calendar_screen.dart';
import 'package:qrn_app/more/json_guide_screen.dart';
import 'package:qrn_app/more/names_99_screen.dart';
import 'package:qrn_app/more/quran_audio_screen.dart';
import 'package:qrn_app/more/quran_pdf_screen.dart';
import 'package:qrn_app/more/tasbeeh_screen.dart';
import 'package:qrn_app/more/zakat_calculator_screen.dart';
import 'package:qrn_app/more/qibla_page.dart';
import 'package:qrn_app/theme/app_surfaces.dart';
import 'package:qrn_app/translations.dart';
import 'package:qrn_app/widgets/themed_asset_icon.dart';
import 'package:qrn_app/widgets/app_main_drawer.dart';
import 'package:qrn_app/navigation/app_navigation.dart';

class MoreTab extends StatelessWidget {
  final bool isDarkMode;
  final String currentLanguage;
  final VoidCallback onNavigateToQibla;
  final VoidCallback? onNavigateToPrayer;

  const MoreTab({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
    required this.onNavigateToQibla,
    this.onNavigateToPrayer,
  });

  static const _primary = Color(0xFF1A5F4A);
  static const _primaryLight = Color(0xFF2D7A62);

  static const _items = [
    _MoreItem(titleKey: 'moreCardPrayerTimes', asset: 'assets/images/more/prayer_times.png'),
    _MoreItem(titleKey: 'moreCardQibla', asset: 'assets/images/more/qibla.png'),
    _MoreItem(titleKey: 'moreCardDuas', asset: 'assets/images/more/duas.png'),
    _MoreItem(titleKey: 'moreCardTasbeeh', asset: 'assets/images/more/tasbeeh.png'),
    _MoreItem(titleKey: 'moreCard99Names', asset: 'assets/images/more/names_99.png'),
    _MoreItem(titleKey: 'moreCardQuranAudio', asset: 'assets/images/more/quran_audio.png'),
    _MoreItem(titleKey: 'moreCardQuranPdf', asset: 'assets/images/more/quran_pdf.png'),
    _MoreItem(titleKey: 'moreCardHowToPray', asset: 'assets/images/more/namaz_tariqa.png'),
    _MoreItem(titleKey: 'moreCardFeelingAyats', asset: 'assets/images/more/feeling_ayat.png'),
    _MoreItem(titleKey: 'moreCardHajj', asset: 'assets/images/more/hajj.png'),
    _MoreItem(titleKey: 'moreCardUmrah', asset: 'assets/images/more/umrah.png'),
    _MoreItem(titleKey: 'moreCardZakat', asset: 'assets/images/more/zakat_calculator.png'),
    _MoreItem(titleKey: 'moreCardIslamicCalendar', asset: 'assets/images/more/islamic_calendar.png'),
  ];

  String _t(String key) => Translations.getText(currentLanguage, key);

  static const _gridAspectRatio = 2.05 * 1.05 * 1.05;

  static const _stripeColors = [
    Color(0xFF1A5F4A),
    Color(0xFF2E7D32),
    Color(0xFF1565C0),
    Color(0xFFF57C00),
    Color(0xFF7B1FA2),
    Color(0xFF00838F),
    Color(0xFFC62828),
    Color(0xFF558B2F),
    Color(0xFF6A1B9A),
    Color(0xFFEF6C00),
    Color(0xFF0277BD),
  ];

  void _onItemTap(BuildContext context, int index) {
    final isDark = isDarkMode;
    final lang = currentLanguage;

    switch (index) {
      case 0:
        onNavigateToPrayer?.call();
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QiblaPage(
              isDarkMode: isDark,
              currentLanguage: lang,
            ),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DuasScreen(isDarkMode: isDark, currentLanguage: lang),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TasbeehScreen(
              isDarkMode: isDark,
              currentLanguage: lang,
            ),
          ),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Names99Screen(
              isDarkMode: isDark,
              currentLanguage: lang,
            ),
          ),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                QuranAudioScreen(isDarkMode: isDark, currentLanguage: lang),
          ),
        );
        break;
      case 6:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuranPdfScreen(
              isDarkMode: isDark,
              currentLanguage: lang,
            ),
          ),
        );
        break;
      case 7:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JsonGuideScreen(
              assetPath: 'assets/data/namaz.json',
              screenTitle: _t('moreCardHowToPray'),
              isDarkMode: isDark,
              currentLanguage: lang,
            ),
          ),
        );
        break;
      case 8:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FeelingAyatsScreen(
              isDarkMode: isDark,
              currentLanguage: lang,
            ),
          ),
        );
        break;
      case 9:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JsonGuideScreen(
              assetPath: 'assets/data/hajj.json',
              screenTitle: _t('moreCardHajj'),
              isDarkMode: isDark,
              currentLanguage: lang,
            ),
          ),
        );
        break;
      case 10:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JsonGuideScreen(
              assetPath: 'assets/data/umrah.json',
              screenTitle: _t('moreCardUmrah'),
              isDarkMode: isDark,
              currentLanguage: lang,
            ),
          ),
        );
        break;
      case 11:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ZakatCalculatorScreen(
              isDarkMode: isDark,
              currentLanguage: lang,
            ),
          ),
        );
        break;
      case 12:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IslamicCalendarScreen(
              isDarkMode: isDark,
              currentLanguage: lang,
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode;

    return Scaffold(
      backgroundColor: AppSurfaces.scaffold(isDark),
      drawer: const AppMainDrawer(),
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          _t('moreSectionTitle'),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => openAppNotifications(context),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: _gridAspectRatio,
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return _MoreSectionCard(
            item: _items[index],
            title: _t(_items[index].titleKey),
            isDark: isDark,
            stripeColor: _stripeColors[index % _stripeColors.length],
            onTap: () => _onItemTap(context, index),
          );
        },
      ),
    );
  }

}

class _MoreItem {
  final String titleKey;
  final String asset;

  const _MoreItem({required this.titleKey, required this.asset});
}

class _MoreSectionCard extends StatelessWidget {
  final _MoreItem item;
  final String title;
  final bool isDark;
  final Color stripeColor;
  final VoidCallback onTap;

  const _MoreSectionCard({
    required this.item,
    required this.title,
    required this.isDark,
    required this.stripeColor,
    required this.onTap,
  });

  static const _iconSize = 46.0 * 1.15 * 1.10 * 1.15 * 1.15;
  static const _stripeWidth = 5.0;

  @override
  Widget build(BuildContext context) {
    final bg = AppSurfaces.card(isDark);

    return Material(
      color: bg,
      elevation: isDark ? 0 : 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(3),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: _stripeWidth,
                color: stripeColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 18, 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ThemedAssetIcon(
                        asset: item.asset,
                        isDark: isDark,
                        size: _iconSize,
                        surfaceColor: bg,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            height: 1.12,
                            color: isDark ? Colors.white : const Color(0xFF1A2E35),
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
      ),
    );
  }
}
