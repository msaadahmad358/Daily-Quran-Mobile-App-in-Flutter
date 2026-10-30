import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:qrn_app/auth_service.dart';
import 'package:qrn_app/translations.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;
  const PaymentHistoryScreen({
    super.key,
    this.isDarkMode = false,
    this.currentLanguage = 'French',
  });
  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  static const _primary = Color(0xFF1A5F4A);
  static const _gold = Color(0xFFC9A96E);
  late Future<Map<String, dynamic>> _f = AuthService().myPayments();

  Color _c(String s) => s == 'paid'
      ? const Color(0xFF2D7A62)
      : (s == 'processing' ? _gold : Colors.redAccent);

  String _t(String key) => Translations.getText(widget.currentLanguage, key);

  String _status(String s) {
    const keys = {
      'paid': 'statusPaid',
      'succeeded': 'statusPaid',
      'failed': 'statusFailed',
      'cancelled': 'statusCancelled',
      'canceled': 'statusCancelled',
      'processing': 'statusProcessing',
      'refunded': 'statusRefunded',
      'pending': 'statusPending',
    };
    final k = keys[s.toLowerCase()];
    if (k != null) return _t(k);
    return s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _fmt(String iso) {
    final d = DateTime.tryParse(iso)?.toLocal();
    if (d == null) return iso;
    return '${_two(d.day)}/${_two(d.month)}/${d.year}  ${_two(d.hour)}:${_two(d.minute)}';
  }

  Future<void> _open(Map<String, dynamic> p) async {
    final u = p['receipt_url'];
    if (u is! String || u.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t('phReceiptOnlyPaid'))));
      return;
    }
    await launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);
  }

  Widget _msg(String t) => ListView(children: [
        const SizedBox(height: 80),
        Icon(Icons.receipt_long_outlined,
            size: 64, color: _gold.withValues(alpha: .8)),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(t,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  color: widget.isDarkMode ? Colors.white70 : Colors.black54)),
        ),
      ]);

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDarkMode;
    return Scaffold(
      backgroundColor:
          dark ? const Color(0xFF0E1A16) : const Color(0xFFF8F5F0),
      appBar: AppBar(
          title: Text(_t('paymentHistory')),
          backgroundColor: _primary,
          foregroundColor: Colors.white),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _f = AuthService().myPayments());
          await _f;
        },
        child: FutureBuilder<Map<String, dynamic>>(
          future: _f,
          builder: (c, s) {
            if (s.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final d = s.data ?? {};
            if (d['success'] != true) {
              return _msg(Translations.apiMessage(
                  widget.currentLanguage, d['message'],
                  fallbackKey: 'phLoadFailed'));
            }
            final list = ((d['payments'] as List?) ?? [])
                .whereType<Map<String, dynamic>>()
                .toList();
            if (list.isEmpty) {
              return _msg(_t('phEmpty'));
            }
            final total = (d['total_paid'] as num?) ?? 0;
            return ListView(padding: const EdgeInsets.all(16), children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF0E3B2E), _primary]),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(children: [
                  Expanded(
                      child: Text(_t('phTotal'),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 15))),
                  Text('€${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: _gold,
                          fontSize: 24,
                          fontWeight: FontWeight.w800)),
                ]),
              ),
              const SizedBox(height: 12),
              ...list.map((p) {
                final st = '${p['status'] ?? ''}';
                final amt = (p['amount'] as num?) ?? 0;
                return Card(
                  color: dark ? Colors.white10 : Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    onTap: () => _open(p),
                    leading: CircleAvatar(
                        backgroundColor: _c(st).withValues(alpha: .15),
                        child: Icon(Icons.volunteer_activism, color: _c(st))),
                    title: Text(
                        '€${amt.toStringAsFixed(2)}  ·  ${p['method_label'] ?? p['method'] ?? ''}',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: dark ? Colors.white : Colors.black87)),
                    subtitle: Text(
                        '${_fmt('${p['date']}')}\n${p['receipt_no'] ?? ''}',
                        style: TextStyle(
                            color: dark ? Colors.white60 : Colors.black54)),
                    isThreeLine: true,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: _c(st).withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                          _status(st),
                          style: TextStyle(
                              color: _c(st),
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ),
                  ),
                );
              }),
            ]);
          },
        ),
      ),
    );
  }
}
