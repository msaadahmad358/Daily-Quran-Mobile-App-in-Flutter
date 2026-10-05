import 'package:flutter/material.dart';
import 'package:qrn_app/translations.dart';
import 'package:qrn_app/widgets/more_page_scaffold.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;

  const ZakatCalculatorScreen({
    super.key,
    required this.isDarkMode,
    this.currentLanguage = 'English',
  });

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  static const _primary = Color(0xFF1A5F4A);
  static const _zakatRate = 0.025;

  static const _goldPricePerGram = 75.0;
  static const _silverPricePerGram = 0.85;
  static const _nisabGoldGrams = 85.0;
  static const _nisabSilverGrams = 595.0;

  final _goldCtrl = TextEditingController();
  final _silverCtrl = TextEditingController();
  final _cashCtrl = TextEditingController();

  String _t(String key) => Translations.getText(widget.currentLanguage, key);

  @override
  void dispose() {
    _goldCtrl.dispose();
    _silverCtrl.dispose();
    _cashCtrl.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final card = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final goldG = _parse(_goldCtrl);
    final silverG = _parse(_silverCtrl);
    final cash = _parse(_cashCtrl);
    final goldValue = goldG * _goldPricePerGram;
    final silverValue = silverG * _silverPricePerGram;
    final totalWealth = goldValue + silverValue + cash;
    final nisabGold = _nisabGoldGrams * _goldPricePerGram;
    final nisabSilver = _nisabSilverGrams * _silverPricePerGram;
    final nisab = nisabGold < nisabSilver ? nisabGold : nisabSilver;
    final due = totalWealth >= nisab ? totalWealth * _zakatRate : 0.0;

    return MorePageScaffold(
      title: _t('moreCardZakat'),
      isDarkMode: isDark,
      currentLanguage: widget.currentLanguage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: card,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  _t('zakatIntro'),
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: isDark ? Colors.grey[300] : Colors.grey[800],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _field(_t('zakatGoldGrams'), _goldCtrl, isDark),
            const SizedBox(height: 12),
            _field(_t('zakatSilverGrams'), _silverCtrl, isDark),
            const SizedBox(height: 12),
            _field(_t('zakatCash'), _cashCtrl, isDark, prefix: '\$'),
            const SizedBox(height: 20),
            Material(
              color: _primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('zakatTotalWealth'),
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                    Text(
                      '\$${totalWealth.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      totalWealth >= nisab
                          ? _t('zakatDue')
                          : _t('zakatBelowNisab'),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                    Text(
                      '\$${due.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1A2E35),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    bool isDark, {
    String? prefix,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
