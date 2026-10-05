import 'package:flutter/material.dart';
import 'package:qrn_app/theme/app_surfaces.dart';
import 'package:qrn_app/translations.dart';
import 'package:qrn_app/widgets/global_surah_audio_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  final bool isDarkMode;
  final String currentLanguage;

  const AboutUsScreen({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
  });

  static const _primary = Color(0xFF1A5F4A);
  static const _website = 'http://hassana.eu';

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode;
    final card = AppSurfaces.card(isDark);
    final getText = (String key) => Translations.getText(currentLanguage, key);

    return Scaffold(
      backgroundColor: AppSurfaces.scaffold(isDark),
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        title: Text(
          getText('aboutUs'),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      bottomNavigationBar: GlobalSurahAudioBar(
        isDarkMode: isDark,
        currentLanguage: currentLanguage,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/logo.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.menu_book_rounded,
                      color: _primary,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              getText('appTitle'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A2E35),
              ),
            ),
            const SizedBox(height: 16),
            Material(
              color: card,
              borderRadius: BorderRadius.circular(3),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  border: const Border(
                    left: BorderSide(color: _primary, width: 5),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  getText('aboutUsBody'),
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: isDark ? Colors.grey[200] : const Color(0xFF2D2D2D),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(_website);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.public_rounded),
              label: Text(getText('visitWebsite')),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primary,
                side: const BorderSide(color: _primary),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
