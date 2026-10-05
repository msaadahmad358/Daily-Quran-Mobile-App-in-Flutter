import 'package:flutter/material.dart';
import 'package:qrn_app/widgets/global_surah_audio_bar.dart';

class MorePageScaffold extends StatelessWidget {
  final String title;
  final bool isDarkMode;
  final String currentLanguage;
  final Widget body;
  final List<Widget>? actions;

  static const primary = Color(0xFF1A5F4A);

  const MorePageScaffold({
    super.key,
    required this.title,
    required this.isDarkMode,
    required this.body,
    this.currentLanguage = 'English',
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F2EE);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: 0.2,
          ),
        ),
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: GlobalSurahAudioBar(
        isDarkMode: isDarkMode,
        currentLanguage: currentLanguage,
      ),
    );
  }
}
