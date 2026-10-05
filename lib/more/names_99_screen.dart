import 'package:flutter/material.dart';
import 'package:qrn_app/data/allah_names_99.dart';
import 'package:qrn_app/theme/app_arabic.dart';
import 'package:qrn_app/translations.dart';
import 'package:qrn_app/widgets/more_page_scaffold.dart';

class Names99Screen extends StatelessWidget {
  final bool isDarkMode;
  final String currentLanguage;

  const Names99Screen({
    super.key,
    required this.isDarkMode,
    this.currentLanguage = 'English',
  });

  static const _primary = Color(0xFF1A5F4A);

  @override
  Widget build(BuildContext context) {
    final isDark = isDarkMode;
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return MorePageScaffold(
      title: Translations.getText(currentLanguage, 'moreCard99Names'),
      isDarkMode: isDark,
      currentLanguage: currentLanguage,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: kAllahNames99.length,
        itemBuilder: (context, i) {
          final name = kAllahNames99[i];
          return Material(
            color: card,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _primary.withValues(alpha: 0.15),
                child: Text(
                  '${name.number}',
                  style: const TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              title: Text(
                name.arabic,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: AppArabic.fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                name.english,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
