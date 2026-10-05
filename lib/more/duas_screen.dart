import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrn_app/theme/app_arabic.dart';
import 'package:qrn_app/translations.dart';
import 'package:qrn_app/utils/localized_json.dart';
import 'package:qrn_app/widgets/global_surah_audio_bar.dart';

class _DuaCategoryGroup {
  final String keyEn;
  final Map<String, dynamic> labels;
  final List<Map<String, dynamic>> duas;

  const _DuaCategoryGroup({
    required this.keyEn,
    required this.labels,
    required this.duas,
  });

  String label(String lang) => LocalizedJson.pick(labels, lang);
}

class DuasScreen extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;

  const DuasScreen({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
  });

  @override
  State<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends State<DuasScreen> {
  static const _primary = Color(0xFF1A5F4A);
  static const _gold = Color(0xFFC9A96E);
  static const _allKey = '__all__';

  List<Map<String, dynamic>> _duas = [];
  List<_DuaCategoryGroup> _categories = [];
  String _screenTitle = '';
  bool _loading = true;

  /// `null` = category home; otherwise category key or [_allKey].
  String? _openCategoryKey;
  final _search = TextEditingController();

  String _t(String key) => Translations.getText(widget.currentLanguage, key);

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString('assets/data/islamic_duas.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    final list = (data['duas'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final buckets = <String, List<Map<String, dynamic>>>{};
    final labelMaps = <String, Map<String, dynamic>>{};

    for (final d in list) {
      final cat = Map<String, dynamic>.from(d['category'] as Map? ?? {});
      final key = cat['en']?.toString() ?? 'Other';
      buckets.putIfAbsent(key, () => []).add(d);
      labelMaps[key] = cat;
    }

    final groups = buckets.entries
        .map(
          (e) => _DuaCategoryGroup(
            keyEn: e.key,
            labels: labelMaps[e.key] ?? {'en': e.key},
            duas: e.value,
          ),
        )
        .toList()
      ..sort(
        (a, b) => a.label(widget.currentLanguage)
            .compareTo(b.label(widget.currentLanguage)),
      );

    if (!mounted) return;
    setState(() {
      _duas = list;
      _categories = groups;
      _screenTitle =
          LocalizedJson.pick(data['title'] as Map?, widget.currentLanguage);
      _loading = false;
    });
  }

  _DuaCategoryGroup? get _openGroup {
    if (_openCategoryKey == null || _openCategoryKey == _allKey) return null;
    for (final g in _categories) {
      if (g.keyEn == _openCategoryKey) return g;
    }
    return null;
  }

  List<Map<String, dynamic>> get _visibleDuas {
    final lang = widget.currentLanguage;
    Iterable<Map<String, dynamic>> source;
    if (_openCategoryKey == null) {
      return const [];
    }
    if (_openCategoryKey == _allKey) {
      source = _duas;
    } else {
      source = _openGroup?.duas ?? const [];
    }

    final q = _search.text.toLowerCase().trim();
    if (q.isEmpty) return source.toList();

    return source.where((d) {
      final title = LocalizedJson.pick(d['title'] as Map?, lang).toLowerCase();
      final meaning = LocalizedJson.duaMeaning(d, lang).toLowerCase();
      final ar = (d['arabic'] ?? '').toString().toLowerCase();
      return title.contains(q) || meaning.contains(q) || ar.contains(q);
    }).toList();
  }

  String get _listTitle {
    if (_openCategoryKey == _allKey) return _t('duasAllCategories');
    return _openGroup?.label(widget.currentLanguage) ?? _t('moreCardDuas');
  }

  void _openCategory(String key) {
    _search.clear();
    setState(() => _openCategoryKey = key);
  }

  void _backToCategories() {
    _search.clear();
    setState(() => _openCategoryKey = null);
  }

  void _openDetail(Map<String, dynamic> dua) {
    final lang = widget.currentLanguage;
    final title = LocalizedJson.pick(dua['title'] as Map?, lang);
    final meaning = LocalizedJson.duaMeaning(dua, lang);
    final category = LocalizedJson.pick(dua['category'] as Map?, lang);
    final isDark = widget.isDarkMode;
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF5F2EE);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            surfaceTintColor: Colors.transparent,
            title: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
          ),
          bottomNavigationBar: GlobalSurahAudioBar(
            isDarkMode: isDark,
            currentLanguage: lang,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (category.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: _gold.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Color(0xFF8B7340),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
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
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                    child: Text(
                      dua['arabic']?.toString() ?? '',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: AppArabic.style(
                        fontSize: 28,
                        height: 1.65,
                        color: isDark ? Colors.white : const Color(0xFF1A2E35),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  color: card,
                  borderRadius: BorderRadius.circular(3),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t('duasMeaning'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          meaning,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.55,
                            color:
                                isDark ? Colors.grey[200] : const Color(0xFF2D2D2D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if ((dua['reference'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 16,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dua['reference'].toString(),
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
    final lang = widget.currentLanguage;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF5F2EE);
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final inList = _openCategoryKey != null;

    return PopScope(
      canPop: !inList,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && inList) _backToCategories();
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
          leading: inList
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: _backToCategories,
                )
              : null,
          title: Text(
            inList
                ? _listTitle
                : (_screenTitle.isNotEmpty ? _screenTitle : _t('moreCardDuas')),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
        ),
        bottomNavigationBar: GlobalSurahAudioBar(
          isDarkMode: isDark,
          currentLanguage: lang,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _primary))
            : inList
                ? _buildDuaList(isDark, card, lang)
                : _buildCategoryHome(isDark, card, lang),
      ),
    );
  }

  Widget _buildCategoryHome(bool isDark, Color card, String lang) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 2),
          child: Text(
            _t('duasPickCategory'),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey[300] : const Color(0xFF1A2E35),
            ),
          ),
        ),
        _CategoryNameTile(
          title: _t('duasAllCategories'),
          isDark: isDark,
          cardColor: card,
          onTap: () => _openCategory(_allKey),
        ),
        const SizedBox(height: 8),
        ..._categories.map(
          (group) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _CategoryNameTile(
              title: group.label(lang),
              isDark: isDark,
              cardColor: card,
              onTap: () => _openCategory(group.keyEn),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDuaList(bool isDark, Color card, String lang) {
    final items = _visibleDuas;
    final searchHint = _t('duasSearchHint');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
          child: Material(
            color: card,
            borderRadius: BorderRadius.circular(3),
            elevation: isDark ? 0 : 0.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: searchHint,
                  border: InputBorder.none,
                  icon: const Icon(Icons.search_rounded, color: _primary),
                  suffixIcon: _search.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => _search.clear(),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    _t('duasNoResults'),
                    style: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final dua = items[i];
                    final title =
                        LocalizedJson.pick(dua['title'] as Map?, lang);
                    final meaning = LocalizedJson.duaMeaning(dua, lang);
                    final isShort = dua['length'] == 'short';
                    final stripe =
                        isShort ? _primary : _gold;

                    return Material(
                      color: card,
                      borderRadius: BorderRadius.circular(3),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _openDetail(dua),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(width: 5, color: stripe),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 12, 4, 12),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                      _primary.withValues(alpha: 0.12),
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      color: _primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    0,
                                    12,
                                    10,
                                    12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF1A2E35),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        dua['arabic']?.toString() ?? '',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.right,
                                        textDirection: TextDirection.rtl,
                                        style: AppArabic.style(
                                          fontSize: 17,
                                          height: 1.45,
                                          color: isDark
                                              ? Colors.grey[200]
                                              : const Color(0xFF1A2E35),
                                        ),
                                      ),
                                      if (meaning.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          meaning,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            height: 1.35,
                                            color: isDark
                                                ? Colors.grey[500]
                                                : Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.chevron_right_rounded,
                                  color: isDark
                                      ? Colors.grey[600]
                                      : Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CategoryNameTile extends StatelessWidget {
  final String title;
  final bool isDark;
  final Color cardColor;
  final VoidCallback onTap;

  static const _primary = Color(0xFF1A5F4A);

  const _CategoryNameTile({
    required this.title,
    required this.isDark,
    required this.cardColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(3),
      elevation: isDark ? 0 : 0.5,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: _primary),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A2E35),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
