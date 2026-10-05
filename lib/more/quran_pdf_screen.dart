import 'package:flutter/material.dart';
import 'package:qrn_app/data/quran_mushaf_pages.dart';
import 'package:qrn_app/more/quran_pdf_viewer_screen.dart';
import 'package:qrn_app/services/quran_data_service.dart';
import 'package:qrn_app/services/quran_pdf_last_read_service.dart';
import 'package:qrn_app/surah_name_v4_font.dart';
import 'package:qrn_app/translations.dart';
import 'package:qrn_app/widgets/more_page_scaffold.dart';

class QuranPdfScreen extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;

  const QuranPdfScreen({
    super.key,
    required this.isDarkMode,
    this.currentLanguage = 'English',
  });

  @override
  State<QuranPdfScreen> createState() => _QuranPdfScreenState();
}

class _QuranPdfScreenState extends State<QuranPdfScreen> {
  static const _primary = Color(0xFF1A5F4A);

  late Map<String, dynamic> _quranData;
  late List<String> _keys;
  bool _loading = true;
  ({int page, String label, int? timestamp})? _lastRead;

  @override
  void initState() {
    super.initState();
    _initData();
    _loadLastRead();
    QuranPdfLastReadService.revision.addListener(_loadLastRead);
  }

  @override
  void dispose() {
    QuranPdfLastReadService.revision.removeListener(_loadLastRead);
    super.dispose();
  }

  Future<void> _loadLastRead() async {
    final data = await QuranPdfLastReadService.load();
    if (mounted) setState(() => _lastRead = data);
  }

  Future<void> _initData() async {
    final svc = QuranDataService.instance;
    if (!svc.isReady) await svc.load();
    setState(() {
      _quranData = svc.surahs;
      _keys = svc.surahKeys;
      _loading = false;
    });
  }

  int _ayahCount(Map<String, dynamic> surah) {
    if (surah.containsKey('total_ayahs')) {
      final t = surah['total_ayahs'];
      if (t is int) return t;
      return int.tryParse('$t') ?? 0;
    }
    final ayahs = surah['ayahs'];
    if (ayahs is List) return ayahs.length;
    if (ayahs is Map) return ayahs.length;
    return 0;
  }

  void _openViewer({required int page, String? title}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranPdfViewerScreen(
          initialPage: page,
          isDarkMode: widget.isDarkMode,
          currentLanguage: widget.currentLanguage,
          title: title,
        ),
      ),
    );
  }

  void _openSurah(int num, String name) {
    _openViewer(page: mushafPageForSurah(num), title: name);
  }

  Widget _buildLastSeenCard(
    bool isDark,
    String Function(String) getText,
    String pageLbl,
  ) {
    final last = _lastRead;
    if (last == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Material(
        color: _primary,
        borderRadius: BorderRadius.circular(3),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openViewer(page: last.page, title: last.label),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getText('continueReading'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        last.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${getText('pdfLastSeen')}: $pageLbl ${last.page}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final divider = isDark ? Colors.white12 : const Color(0xFFE0E0E0);

    final getText = (String key) =>
        Translations.getText(widget.currentLanguage, key);
    final pageLbl = getText('pageLabel');

    return MorePageScaffold(
      title: getText('moreCardQuranPdf'),
      isDarkMode: isDark,
      currentLanguage: widget.currentLanguage,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _keys.length + (_lastRead != null ? 1 : 0),
              itemBuilder: (context, index) {
                if (_lastRead != null && index == 0) {
                  return _buildLastSeenCard(isDark, getText, pageLbl);
                }
                final listIndex = _lastRead != null ? index - 1 : index;
                final key = _keys[listIndex];
                final surah = _quranData[key] as Map<String, dynamic>;
                final name = surah['surah_name_en']?.toString() ??
                    key.replaceAll('_', ' ');
                final num = surah['surah_number'] is int
                    ? surah['surah_number'] as int
                    : int.tryParse('${surah['surah_number']}') ??
                        listIndex + 1;

                return Material(
                  color: card,
                  child: InkWell(
                    onTap: () => _openSurah(num, name),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 11,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _primary,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  '$num',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : _primary,
                                      ),
                                    ),
                                    Text(
                                      '${_ayahCount(surah)} verses',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                SurahNameV4Font.glyph(num),
                                style: const TextStyle(
                                  fontFamily: SurahNameV4Font.family,
                                  fontSize: 28,
                                  color: _primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (listIndex < _keys.length - 1)
                          Divider(height: 1, color: divider),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
