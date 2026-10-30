import 'package:flutter/material.dart';

import 'package:qrn_app/auth_service.dart';
import 'package:qrn_app/translations.dart';

/// One screen: email -> "Continue" (account check) -> new password + confirm.
class ForgotPasswordScreen extends StatefulWidget {
  final bool isDarkMode;
  final String currentLanguage;
  final String initialEmail;

  const ForgotPasswordScreen({
    super.key,
    required this.isDarkMode,
    required this.currentLanguage,
    this.initialEmail = '',
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const _primary = Color(0xFF1A5F4A);
  static const _gold = Color(0xFFC9A96E);

  late final TextEditingController _email =
      TextEditingController(text: widget.initialEmail);
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  final _auth = AuthService();

  bool _checking = false;
  bool _saving = false;
  bool _emailOk = false;
  String _checkedEmail = '';
  bool _hide = true;
  String? _msg;
  bool _msgOk = false;

  String _t(String key) => Translations.getText(widget.currentLanguage, key);

  String _api(Object? message, String fallbackKey) => Translations.apiMessage(
      widget.currentLanguage, message,
      fallbackKey: fallbackKey);

  /// Shows the message in a banner at the TOP of the screen.
  void _show(String m, {bool ok = false}) {
    setState(() {
      _msg = m;
      _msgOk = ok;
    });
  }

  Future<void> _check() async {
    FocusScope.of(context).unfocus();
    final e = _email.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e)) {
      _show(_t('fpInvalidEmail'));
      return;
    }
    setState(() {
      _checking = true;
      _msg = null;
    });
    final r = await _auth.checkEmail(email: e);
    if (!mounted) return;
    setState(() {
      _checking = false;
      _emailOk = r['success'] == true;
      _checkedEmail = _emailOk ? e : '';
    });
    _show(
      _emailOk
          ? _t('fpAccountFound')
          : _api(r['message'], 'fpNoAccount'),
      ok: _emailOk,
    );
  }

  Future<void> _reset() async {
    FocusScope.of(context).unfocus();
    final err = _auth.validatePassword(_pw.text);
    if (err != null) {
      _show(_api(err, 'genericFailed'));
      return;
    }
    if (_pw.text != _pw2.text) {
      _show(_t('passwordsMismatch'));
      return;
    }
    setState(() {
      _saving = true;
      _msg = null;
    });
    final r = await _auth.resetPassword(
      email: _checkedEmail,
      newPassword: _pw.text,
      confirmPassword: _pw2.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (r['success'] == true) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          content: Text(
            _t('fpUpdated'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(_t('ok')),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } else {
      _show(_api(r['message'], 'genericFailed'));
    }
  }

  Widget _banner() {
    if (_msg == null) return const SizedBox.shrink();
    final c = _msgOk ? Colors.green.shade700 : Colors.red.shade700;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        border: Border.all(color: c),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(_msgOk ? Icons.check_circle : Icons.error_outline, color: c),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_msg!,
                style: TextStyle(color: c, fontWeight: FontWeight.w600)),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close, size: 18, color: c),
            onPressed: () => setState(() => _msg = null),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon, {Widget? suffix}) {
    final dark = widget.isDarkMode;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: dark ? _gold : _primary),
      suffixIcon: suffix,
      filled: true,
      fillColor: dark ? Colors.white10 : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: dark ? Colors.white24 : Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primary, width: 1.6),
      ),
    );
  }

  Widget _button(String text, bool busy, VoidCallback onTap) => SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: busy ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.4, color: Colors.white))
              : Text(text,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDarkMode;
    final fg = dark ? Colors.white : const Color(0xFF1A1A1A);
    final eye = IconButton(
      icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
      onPressed: () => setState(() => _hide = !_hide),
    );
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0E1A16) : const Color(0xFFF8F5F0),
      appBar: AppBar(
        title: Text(_t('fpTitle')),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            _banner(),
            Icon(Icons.lock_reset_rounded, size: 56, color: dark ? _gold : _primary),
            const SizedBox(height: 12),
            Text(
              _t('fpIntro'),
              textAlign: TextAlign.center,
              style: TextStyle(color: fg.withValues(alpha: .75), height: 1.4),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              style: TextStyle(color: fg),
              decoration: _dec(_t('email'), Icons.email_outlined),
              onChanged: (v) {
                if (_emailOk && v.trim() != _checkedEmail) {
                  setState(() {
                    _emailOk = false;
                    _msg = null;
                  });
                }
              },
            ),
            const SizedBox(height: 14),
            if (!_emailOk)
              _button(_t('fpContinue'), _checking, _check),
            if (_emailOk) ...[
              const SizedBox(height: 28),
              Divider(color: fg.withValues(alpha: .15)),
              const SizedBox(height: 16),
              const SizedBox(height: 6),
              TextField(
                controller: _pw,
                obscureText: _hide,
                style: TextStyle(color: fg),
                decoration: _dec(_t('newPassword'),
                    Icons.lock_outline,
                    suffix: eye),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _pw2,
                obscureText: _hide,
                style: TextStyle(color: fg),
                decoration: _dec(
                    _t('confirmNewPassword'),
                    Icons.lock_outline),
              ),
              const SizedBox(height: 8),
              Text(
                _t('fpRule'),
                style: TextStyle(color: fg.withValues(alpha: .6), fontSize: 12),
              ),
              const SizedBox(height: 18),
              _button(_t('fpUpdateButton'),
                  _saving, _reset),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }
}
