import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrn_app/theme/app_arabic.dart';
import 'package:qrn_app/translations.dart';
import 'package:qrn_app/utils/localized_json.dart';
import 'package:qrn_app/widgets/more_page_scaffold.dart';

class FeelingAyatsScreen extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;

  const FeelingAyatsScreen({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
  });

  @override
  State<FeelingAyatsScreen> createState() => _FeelingAyatsScreenState();
}

class _FeelingAyatsScreenState extends State<FeelingAyatsScreen> {
  List<Map<String, dynamic>> _topics = [];
  String _screenTitle = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString('assets/data/feeling_ayats.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    setState(() {
      _screenTitle = LocalizedJson.pick(
        data['title'] as Map?,
        widget.currentLanguage,
      );
      _topics = (data['topics'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      _loading = false;
    });
  }

  void _openTopic(Map<String, dynamic> topic) {
    final ayahs = (topic['ayahs'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];
    final title = LocalizedJson.pick(
      topic['title'] as Map?,
      widget.currentLanguage,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MorePageScaffold(
          title: title,
          isDarkMode: widget.isDarkMode,
          currentLanguage: widget.currentLanguage,
          body: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: ayahs.length,
            itemBuilder: (context, i) {
              final a = ayahs[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        a['arabic']?.toString() ?? '',
                        textAlign: TextAlign.right,
                        style: AppArabic.style(fontSize: 20, height: 1.55),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        LocalizedJson.meaningField(a, widget.currentLanguage),
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a['reference']?.toString() ?? '',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1A5F4A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final ayahWord = Translations.getText(widget.currentLanguage, 'ayahsCount');

    return MorePageScaffold(
      title: _screenTitle.isNotEmpty
          ? _screenTitle
          : Translations.getText(widget.currentLanguage, 'moreCardFeelingAyats'),
      isDarkMode: isDark,
      currentLanguage: widget.currentLanguage,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _topics.length,
              itemBuilder: (context, i) {
                final topic = _topics[i];
                final title = LocalizedJson.pick(
                  topic['title'] as Map?,
                  widget.currentLanguage,
                );
                final count = (topic['ayahs'] as List?)?.length ?? 0;
                return ListTile(
                  title: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : null,
                    ),
                  ),
                  subtitle: Text('$count $ayahWord'),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF1A5F4A),
                  ),
                  onTap: () => _openTopic(topic),
                );
              },
            ),
    );
  }
}
