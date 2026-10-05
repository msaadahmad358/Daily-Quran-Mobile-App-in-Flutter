import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrn_app/theme/app_arabic.dart';
import 'package:qrn_app/utils/json_section_labels.dart';
import 'package:qrn_app/utils/localized_json.dart';
import 'package:qrn_app/widgets/more_page_scaffold.dart';

class JsonGuideScreen extends StatefulWidget {
  final String assetPath;
  final String screenTitle;
  final bool isDarkMode;
  final String currentLanguage;

  const JsonGuideScreen({
    super.key,
    required this.assetPath,
    required this.screenTitle,
    required this.isDarkMode,
    required this.currentLanguage,
  });

  @override
  State<JsonGuideScreen> createState() => _JsonGuideScreenState();
}

class _JsonGuideScreenState extends State<JsonGuideScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString(widget.assetPath);
    setState(() {
      _data = Map<String, dynamic>.from(json.decode(raw) as Map);
      _loading = false;
    });
  }

  String _t(dynamic v) {
    if (v is Map<String, dynamic>) {
      return LocalizedJson.pick(v, widget.currentLanguage);
    }
    return v?.toString() ?? '';
  }

  String _textFromItem(Map<String, dynamic> item) {
    final lang = widget.currentLanguage;
    if (lang == 'French' && (item['french'] ?? '').toString().isNotEmpty) {
      return item['french'].toString();
    }
    if ((item['english'] ?? '').toString().isNotEmpty) {
      return item['english'].toString();
    }
    return LocalizedJson.pick(item, lang);
  }

  Widget _bodyText(String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(height: 1.45, fontSize: 14)),
    );
  }

  List<Widget> _buildStepTiles(List list) {
    return list.map((raw) {
      final step = Map<String, dynamic>.from(raw as Map);
      final title = _t(step['name'] ?? step['title'] ?? step['day']);
      final desc = _t(step['description']);
      final ar = step['arabic']?.toString() ?? '';
      final body = _textFromItem(step);
      return ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (desc.isNotEmpty) _bodyText(desc),
                if (body.isNotEmpty && body != desc) _bodyText(body),
                if (ar.isNotEmpty)
                  Text(
                    ar,
                    textAlign: TextAlign.right,
                    style: AppArabic.style(fontSize: 18, height: 1.5),
                  ),
                if ((step['reference'] ?? '').toString().isNotEmpty)
                  Text(
                    step['reference'].toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  List<Widget> _buildItemTiles(List list) {
    return list.map((raw) {
      final item = Map<String, dynamic>.from(raw as Map);
      final title = _textFromItem(item);
      final ar = item['ar']?.toString() ?? '';
      return ListTile(
        dense: true,
        title: Text(title),
        subtitle: ar.isNotEmpty
            ? Text(
                ar,
                textAlign: TextAlign.right,
                style: AppArabic.style(fontSize: 16),
              )
            : null,
      );
    }).toList();
  }

  List<Widget> _sectionsFromData(Map<String, dynamic> data) {
    final skip = {'id', 'title', 'description', 'note', 'counts'};
    final widgets = <Widget>[];

    for (final entry in data.entries) {
      if (skip.contains(entry.key)) continue;
      final key = entry.key;
      final value = entry.value;

      if (value is List) {
        widgets.add(
          ExpansionTile(
            title: Text(
              JsonSectionLabels.label(key, widget.currentLanguage),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            children: key == 'steps' || key == 'days' || key == 'types'
                ? _buildStepTiles(value)
                : _buildItemTiles(value),
          ),
        );
      } else if (value is Map<String, dynamic>) {
        final title = value.containsKey('title')
            ? _t(value['title'])
            : _formatKey(key);
        final children = <Widget>[];
        if (value['english'] != null || value['french'] != null) {
          children.add(
            Padding(
              padding: const EdgeInsets.all(16),
              child: _bodyText(_textFromItem(value)),
            ),
          );
        }
        if (value['items'] is List) {
          children.addAll(_buildItemTiles(value['items'] as List));
        }
        if (value['steps'] is List) {
          children.addAll(_buildStepTiles(value['steps'] as List));
        }
        if (children.isEmpty && !value.containsKey('title')) {
          children.add(
            Padding(
              padding: const EdgeInsets.all(16),
              child: _bodyText(_t(value)),
            ),
          );
        }
        widgets.add(
          ExpansionTile(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            children: children,
          ),
        );
      } else if (value is Map) {
        final m = Map<String, dynamic>.from(value);
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _bodyText(_t(m)),
          ),
        );
      }
    }
    return widgets;
  }

  String _formatKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}')
        .replaceFirstMapped(
          RegExp(r'^.'),
          (m) => m.group(0)!.toUpperCase(),
        )
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    final appBarTitle = _data != null && _data!['title'] != null
        ? _t(_data!['title'])
        : widget.screenTitle;

    return MorePageScaffold(
      title: appBarTitle,
      isDarkMode: isDark,
      currentLanguage: widget.currentLanguage,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('Failed to load'))
              : ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    if (_data!['title'] != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          _t(_data!['title']),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A5F4A),
                          ),
                        ),
                      ),
                    if (_data!['description'] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _bodyText(_t(_data!['description'])),
                      ),
                    if (_data!['note'] != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _t(_data!['note']),
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                      ),
                    ..._sectionsFromData(_data!),
                  ],
                ),
    );
  }
}
