import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrn_app/services/tasbeeh_storage_service.dart';
import 'package:qrn_app/theme/app_arabic.dart';
import 'package:qrn_app/translations.dart';
import 'package:qrn_app/widgets/more_page_scaffold.dart';

class TasbeehScreen extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;

  const TasbeehScreen({
    super.key,
    required this.isDarkMode,
    this.currentLanguage = 'English',
  });

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen>
    with TickerProviderStateMixin {
  static const _primary = Color(0xFF1A5F4A);
  static const _gold = Color(0xFFC9A96E);

  List<TasbeehDhikr> _items = [];
  Map<String, int> _counts = {};
  String? _selectedId;
  bool _loading = true;

  late AnimationController _tapPulse;
  late AnimationController _ringPulse;

  String _t(String key) => Translations.getText(widget.currentLanguage, key);

  TasbeehDhikr? get _selected {
    if (_selectedId == null) return null;
    for (final d in _items) {
      if (d.id == _selectedId) return d;
    }
    return _items.isNotEmpty ? _items.first : null;
  }

  int get _count => _selected == null ? 0 : (_counts[_selected!.id] ?? 0);

  @override
  void initState() {
    super.initState();
    _tapPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _ringPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final items = await TasbeehStorageService.loadAll();
    final counts = await TasbeehStorageService.loadCounts();
    var selected = await TasbeehStorageService.loadSelectedId();
    if (selected == null || !items.any((e) => e.id == selected)) {
      selected = items.isNotEmpty ? items.first.id : null;
    }
    if (!mounted) return;
    setState(() {
      _items = items;
      _counts = counts;
      _selectedId = selected;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tapPulse.dispose();
    _ringPulse.dispose();
    super.dispose();
  }

  Future<void> _selectDhikr(TasbeehDhikr d) async {
    setState(() => _selectedId = d.id);
    await TasbeehStorageService.saveSelectedId(d.id);
  }

  Future<void> _setCount(int value) async {
    final sel = _selected;
    if (sel == null) return;
    final v = value.clamp(0, 999999);
    setState(() => _counts[sel.id] = v);
    await TasbeehStorageService.saveCount(sel.id, v);
  }

  Future<void> _increment() async {
    final sel = _selected;
    if (sel == null) return;

    HapticFeedback.mediumImpact();
    _tapPulse.forward(from: 0).then((_) => _tapPulse.reverse());

    final next = _count + 1;
    await _setCount(next);

    if (next % sel.target == 0) {
      HapticFeedback.heavyImpact();
      _ringPulse.forward(from: 0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_t('tasbeehRoundComplete')),
            backgroundColor: _primary,
            duration: const Duration(milliseconds: 1200),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _decrement() async {
    if (_count <= 0) return;
    HapticFeedback.selectionClick();
    await _setCount(_count - 1);
  }

  Future<void> _reset() async {
    final sel = _selected;
    if (sel == null) return;
    HapticFeedback.lightImpact();
    await _setCount(0);
  }

  Future<void> _showAddCustomDialog() async {
    final arabicCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '33');

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = widget.isDarkMode;
        final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _t('tasbeehAddCustom'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1A2E35),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: arabicCtrl,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                  style: AppArabic.style(fontSize: 22, color: _primary),
                  decoration: InputDecoration(
                    labelText: _t('tasbeehArabicLabel'),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: targetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _t('tasbeehTargetCount'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    final ar = arabicCtrl.text.trim();
                    final target = int.tryParse(targetCtrl.text.trim()) ?? 33;
                    if (ar.isEmpty) return;
                    Navigator.pop(ctx, true);
                    _addCustom(ar, target.clamp(1, 9999));
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(_t('tasbeehSave')),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (saved != true) {
      arabicCtrl.dispose();
      targetCtrl.dispose();
    }
  }

  Future<void> _addCustom(String arabic, int target) async {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final item = TasbeehDhikr(
      id: id,
      arabic: arabic,
      target: target,
      isCustom: true,
    );
    final custom = _items.where((e) => e.isCustom).toList()..add(item);
    await TasbeehStorageService.saveCustomList(custom);
    final items = await TasbeehStorageService.loadAll();
    if (!mounted) return;
    setState(() => _items = items);
    await _selectDhikr(item);
  }

  Future<void> _deleteCustom(TasbeehDhikr d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_t('tasbeehDelete')),
        content: Text(
          d.arabic,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: AppArabic.style(fontSize: 20, color: _primary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(_t('tasbeehDelete')),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final custom = _items.where((e) => e.isCustom && e.id != d.id).toList();
    await TasbeehStorageService.saveCustomList(custom);
    await TasbeehStorageService.clearCount(d.id);
    final items = await TasbeehStorageService.loadAll();
    if (!mounted) return;
    var selected = _selectedId;
    if (selected == d.id) {
      selected = items.isNotEmpty ? items.first.id : null;
      if (selected != null) {
        await TasbeehStorageService.saveSelectedId(selected);
      }
    }
    setState(() {
      _items = items;
      _selectedId = selected;
    });
  }

  Future<void> _setTargetQuick(int target) async {
    final sel = _selected;
    if (sel == null || !sel.isCustom) return;
    final updated = sel.copyWith(target: target);
    final custom = _items.where((e) => e.isCustom).map((e) {
      return e.id == sel.id ? updated : e;
    }).toList();
    await TasbeehStorageService.saveCustomList(custom);
    final items = await TasbeehStorageService.loadAll();
    if (!mounted) return;
    setState(() => _items = items);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final sel = _selected;

    return MorePageScaffold(
      title: _t('moreCardTasbeeh'),
      isDarkMode: isDark,
      currentLanguage: widget.currentLanguage,
      actions: [
        IconButton(
          tooltip: _t('tasbeehAddCustom'),
          onPressed: _showAddCustomDialog,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _primary),
            )
          : sel == null
              ? Center(child: Text(_t('tasbeehAddCustom')))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 118,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final d = _items[index];
                          final selected = d.id == _selectedId;
                          final c = _counts[d.id] ?? 0;
                          return _DhikrPickerCard(
                            dhikr: d,
                            selected: selected,
                            count: c,
                            isDark: isDark,
                            cardColor: card,
                            onTap: () => _selectDhikr(d),
                            onLongPress: d.isCustom
                                ? () => _deleteCustom(d)
                                : null,
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          children: [
                            _ArabicDhikrBanner(
                              arabic: sel.arabic,
                              isDark: isDark,
                              cardColor: card,
                            ),
                            const SizedBox(height: 20),
                            _CounterRing(
                              count: _count,
                              target: sel.target,
                              isDark: isDark,
                              tapPulse: _tapPulse,
                              ringPulse: _ringPulse,
                              onTap: _increment,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _StatPill(
                                  label: _t('tasbeehTarget'),
                                  value: '${sel.target}',
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 10),
                                _StatPill(
                                  label: _t('tasbeehRounds'),
                                  value: sel.target == 0
                                      ? '0'
                                      : '${_count ~/ sel.target}',
                                  isDark: isDark,
                                  accent: _gold,
                                ),
                                const SizedBox(width: 10),
                                _StatPill(
                                  label: _t('tasbeehInRound'),
                                  value:
                                      '${sel.target == 0 ? 0 : _count % sel.target}',
                                  isDark: isDark,
                                ),
                              ],
                            ),
                            if (sel.isCustom) ...[
                              const SizedBox(height: 14),
                              Text(
                                _t('tasbeehQuickTarget'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                alignment: WrapAlignment.center,
                                children: [33, 99, 100, 500].map((n) {
                                  final on = sel.target == n;
                                  return FilterChip(
                                    label: Text('$n'),
                                    selected: on,
                                    onSelected: (_) => _setTargetQuick(n),
                                    selectedColor:
                                        _primary.withValues(alpha: 0.2),
                                    checkmarkColor: _primary,
                                  );
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed:
                                        _count > 0 ? _decrement : null,
                                    icon: const Icon(Icons.remove_rounded),
                                    label: Text(_t('tasbeehUndo')),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: _primary,
                                      side: const BorderSide(color: _primary),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: _reset,
                                    icon: const Icon(Icons.refresh_rounded),
                                    label: Text(_t('tasbeehReset')),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _primary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _t('tasbeehTapToCount'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                            ),
                            if (_items.any((e) => e.isCustom))
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  _t('tasbeehLongPressDelete'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.grey[600]
                                        : Colors.grey[500],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _DhikrPickerCard extends StatelessWidget {
  final TasbeehDhikr dhikr;
  final bool selected;
  final int count;
  final bool isDark;
  final Color cardColor;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  static const _primary = Color(0xFF1A5F4A);

  const _DhikrPickerCard({
    required this.dhikr,
    required this.selected,
    required this.count,
    required this.isDark,
    required this.cardColor,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(3),
      elevation: selected ? 2 : 0,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          width: 132,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: selected
                  ? _primary
                  : (isDark ? Colors.white12 : const Color(0xFFE8E4DE)),
              width: selected ? 2 : 1,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: selected ? _primary : _primary.withValues(alpha: 0.35),
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(3),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          dhikr.arabic,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: AppArabic.style(
                            fontSize: 15,
                            height: 1.35,
                            color: selected
                                ? _primary
                                : (isDark ? Colors.white : const Color(0xFF1A2E35)),
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                            ),
                            Text(
                              '/ ${dhikr.target}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        if (dhikr.isCustom)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(
                              Icons.edit_note_rounded,
                              size: 14,
                              color: isDark ? Colors.grey[600] : Colors.grey[400],
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
      ),
    );
  }
}

class _ArabicDhikrBanner extends StatelessWidget {
  final String arabic;
  final bool isDark;
  final Color cardColor;

  static const _primary = Color(0xFF1A5F4A);
  static const _gold = Color(0xFFC9A96E);

  const _ArabicDhikrBanner({
    required this.arabic,
    required this.isDark,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          left: BorderSide(color: _primary, width: 5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        children: [
          Icon(Icons.auto_awesome, color: _gold.withValues(alpha: 0.9), size: 22),
          const SizedBox(height: 12),
          Text(
            arabic,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: AppArabic.style(
              fontSize: 34,
              height: 1.5,
              color: _primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterRing extends StatelessWidget {
  final int count;
  final int target;
  final bool isDark;
  final AnimationController tapPulse;
  final AnimationController ringPulse;
  final VoidCallback onTap;

  static const _primary = Color(0xFF1A5F4A);
  static const _gold = Color(0xFFC9A96E);

  const _CounterRing({
    required this.count,
    required this.target,
    required this.isDark,
    required this.tapPulse,
    required this.ringPulse,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inRound = target <= 0 ? 0 : count % target;
    final progress = target <= 0
        ? 0.0
        : (inRound == 0 && count > 0 ? target : inRound) / target;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([tapPulse, ringPulse]),
        builder: (context, child) {
          final scale = 1.0 - (tapPulse.value * 0.06);
          final glow = ringPulse.value;
          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(260, 260),
                    painter: _RingPainter(
                      progress: progress,
                      glow: glow,
                      trackColor: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : _primary.withValues(alpha: 0.12),
                      progressColor: _primary,
                      completeColor: _gold,
                    ),
                  ),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: isDark
                            ? [
                                const Color(0xFF252525),
                                const Color(0xFF1A1A1A),
                              ]
                            : [
                                Colors.white,
                                const Color(0xFFF0EBE3),
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _primary.withValues(alpha: 0.15 + glow * 0.2),
                          blurRadius: 24 + glow * 12,
                          spreadRadius: glow * 4,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : _primary,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(progress * 100).round()}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double glow;
  final Color trackColor;
  final Color progressColor;
  final Color completeColor;

  _RingPainter({
    required this.progress,
    required this.glow,
    required this.trackColor,
    required this.progressColor,
    required this.completeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const stroke = 12.0;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final prog = Paint()
      ..color = progress >= 1 ? completeColor : progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);

    if (progress > 0) {
      final sweep = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweep,
        false,
        prog,
      );
    }

    if (glow > 0) {
      final glowPaint = Paint()
        ..color = completeColor.withValues(alpha: 0.25 * (1 - glow))
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke + 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.glow != glow;
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color? accent;

  const _StatPill({
    required this.label,
    required this.value,
    required this.isDark,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final c = accent ?? const Color(0xFF1A5F4A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE8E4DE),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}
