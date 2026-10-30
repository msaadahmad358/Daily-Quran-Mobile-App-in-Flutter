import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:qrn_app/translations.dart';
import 'package:qrn_app/widgets/more_page_scaffold.dart';

class IslamicCalendarScreen extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;

  const IslamicCalendarScreen({
    super.key,
    required this.isDarkMode,
    this.currentLanguage = 'English',
  });

  @override
  State<IslamicCalendarScreen> createState() => _IslamicCalendarScreenState();
}

class _IslamicCalendarScreenState extends State<IslamicCalendarScreen> {
  List<Map<String, dynamic>> _days = [];
  bool _loading = true;
  String? _error;
  String _monthLabel = '';

  String _t(String key) => Translations.getText(widget.currentLanguage, key);

  bool get _isFrench => widget.currentLanguage == 'French';

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  String _hijriMonthLabel(Map<String, dynamic>? hijri) {
    if (hijri == null) return '';
    final month = hijri['month'] as Map?;
    if (_isFrench) {
      return '${month?['fr'] ?? month?['en'] ?? ''} ${hijri['year'] ?? ''}';
    }
    return '${month?['en'] ?? ''} ${hijri['year'] ?? ''}';
  }

  String _gregLine(Map? greg) {
    if (greg == null) return '';
    final dateStr = greg['date']?.toString() ?? '';
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final d = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        final locale = _isFrench ? 'fr_FR' : 'en_US';
        return DateFormat('EEEE d MMMM', locale).format(d);
      }
    } catch (_) {}
    final weekday = greg['weekday'] as Map?;
    final w = _isFrench
        ? (weekday?['fr'] ?? weekday?['en'] ?? '')
        : (weekday?['en'] ?? '');
    return '$w ${greg['day'] ?? ''} ${greg['month']?['en'] ?? ''}';
  }

  String _hijriLine(Map? hijri) {
    if (hijri == null) return '';
    final month = hijri['month'] as Map?;
    final m = _isFrench
        ? (month?['fr'] ?? month?['ar'] ?? month?['en'] ?? '')
        : (month?['en'] ?? month?['ar'] ?? '');
    return '${hijri['day'] ?? ''} $m ${hijri['year'] ?? ''}';
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final now = DateTime.now();
    final url =
        'https://api.aladhan.com/v1/gToHCalendar/${now.month}/${now.year}';
    try {
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final data = json['data'] as List?;
      if (data == null || data.isEmpty) throw Exception('No data');
      final first = data.first as Map<String, dynamic>;
      final hijri = first['hijri'] as Map<String, dynamic>?;
      _monthLabel = hijri != null
          ? _hijriMonthLabel(hijri)
          : '${now.month}/${now.year}';
      _days = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = _t('calendarLoadError');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return MorePageScaffold(
      title: _t('moreCardIslamicCalendar'),
      isDarkMode: isDark,
      currentLanguage: widget.currentLanguage,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      TextButton(
                        onPressed: _fetch,
                        child: Text(_t('retry')),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _monthLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A5F4A),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _days.length,
                        itemBuilder: (context, i) {
                          final day = _days[i];
                          final greg = day['gregorian'];
                          final hijri = day['hijri'];
                          return Material(
                            color: i.isEven ? card : null,
                            child: ListTile(
                              title: Text(
                                _gregLine(greg),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : null,
                                ),
                              ),
                              subtitle: Text(_hijriLine(hijri)),
                              trailing: Text(
                                hijri?['day']?.toString() ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A5F4A),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
