import 'package:flutter/material.dart';
import 'package:qrn_app/theme/app_arabic.dart';
import 'auth_service.dart';
import 'translations.dart';
import 'base_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback onSignup;
  final VoidCallback onForgotPassword;
  final VoidCallback onSkipLogin;
  final String currentLanguage;
  final bool isDarkMode;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onSignup,
    required this.onForgotPassword,
    required this.onSkipLogin,
    required this.currentLanguage,
    required this.isDarkMode,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseScreenState<LoginScreen> {
  static const _primary = Color(0xFF1A5F4A);
  static const _gold = Color(0xFFC9A96E);

  bool _isLogin = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  bool _obscurePassword = true;
  bool _showVerification = false;
  String _verificationEmail = '';

  final AuthService _auth = AuthService();

  InputDecoration _fieldDecoration({
    required String label,
    required bool isDark,
    required Widget prefix,
    Widget? suffix,
  }) {
    final fill = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final border = isDark ? Colors.white12 : const Color(0xFFE8E4DE);
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.grey[400] : Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(3),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final getText = (String key) => Translations.getText(widget.currentLanguage, key);
    final canPop = Navigator.canPop(context);
    final sheetBg = isDark ? const Color(0xFF121212) : const Color(0xFFF5F2EE);

    return Scaffold(
      backgroundColor: _primary,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 28),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (canPop)
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        )
                      else
                        const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          getText('appTitleShort'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: canPop ? 48 : 8),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _gold.withValues(alpha: 0.5), width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/logo.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.menu_book_rounded, color: _primary, size: 36),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _showVerification
                        ? getText('verifyYourEmail')
                        : (_isLogin ? getText('welcome') : getText('welcomeDesc')),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_showVerification) ...[
                      _AuthModeTabs(
                        isLogin: _isLogin,
                        loginLabel: getText('login'),
                        signupLabel: getText('signup'),
                        onLogin: () => setState(() => _isLogin = true),
                        onSignup: () => setState(() => _isLogin = false),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 22),
                    ],
                    if (_showVerification)
                      _buildVerification(isDark, getText)
                    else
                      _buildCredentials(isDark, getText),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentials(bool isDark, String Function(String) getText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          keyboardType: TextInputType.emailAddress,
          decoration: _fieldDecoration(
            label: getText('email'),
            isDark: isDark,
            prefix: const Icon(Icons.email_outlined, color: _primary),
          ),
        ),
        if (!_isLogin) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: _fieldDecoration(
              label: getText('fullName'),
              isDark: isDark,
              prefix: const Icon(Icons.person_outline, color: _primary),
            ),
          ),
        ],
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: _fieldDecoration(
            label: getText('password'),
            isDark: isDark,
            prefix: const Icon(Icons.lock_outline, color: _primary),
            suffix: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        if (_isLogin) ...[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onForgotPassword,
              child: Text(
                getText('forgotPassword'),
                style: const TextStyle(color: _primary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ] else
          const SizedBox(height: 8),
        const SizedBox(height: 8),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: _isLoading ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: _primary,
              disabledBackgroundColor: _primary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    _isLogin ? getText('login') : getText('signup'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            textDirection: TextDirection.rtl,
            style: AppArabic.style(
              fontSize: 16,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerification(bool isDark, String Function(String) getText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${getText('enterVerificationCode')} $_verificationEmail',
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _codeController,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          decoration: _fieldDecoration(
            label: getText('verificationCode'),
            isDark: isDark,
            prefix: const Icon(Icons.pin_outlined, color: _primary),
          ).copyWith(counterText: ''),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: _isLoading ? null : _verifyEmail,
            style: FilledButton.styleFrom(
              backgroundColor: _primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    getText('verify'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _resendCode,
          child: Text(
            getText('resendCode'),
            style: const TextStyle(color: _primary, fontWeight: FontWeight.w600),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _showVerification = false),
          child: Text(
            getText('backToLogin'),
            style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isLogin) {
      final result = await _auth.login(email: email, password: password);

      if (result['success'] == true) {
        widget.onLogin();
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      } else {
        if (result['data'] != null && result['data']['requires_verification'] == true) {
          setState(() {
            _verificationEmail = email;
            _showVerification = true;
            _isLoading = false;
          });
          return;
        }
        _showError(result['message'] ?? getText('loginFailed'));
      }
    } else {
      final name = _nameController.text.trim();

      if (name.isEmpty) {
        _showError(getText('nameCannotBeEmpty'));
        setState(() => _isLoading = false);
        return;
      }

      final result = await _auth.register(email: email, password: password, name: name);

      if (result['success'] == true) {
        setState(() {
          _verificationEmail = email;
          _showVerification = true;
          _isLoading = false;
        });
        _showSuccess(getText('codeSentSuccess'));
      } else {
        _showError(result['message'] ?? getText('registrationFailed'));
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _verifyEmail() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      _showError(getText('enter6DigitCode'));
      return;
    }

    setState(() => _isLoading = true);

    final result = await _auth.verifyEmail(email: _verificationEmail, code: code);

    if (result['success'] == true) {
      widget.onLogin();
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
    } else {
      _showError(result['message'] ?? getText('verificationFailed'));
    }

    setState(() => _isLoading = false);
  }

  Future<void> _resendCode() async {
    setState(() => _isLoading = true);

    final result = await _auth.resendVerificationCode(email: _verificationEmail);

    if (result['success'] == true) {
      _showSuccess(getText('newCodeSent'));
    } else {
      _showError(result['message'] ?? getText('resendCodeFailed'));
    }

    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }
}

class _AuthModeTabs extends StatelessWidget {
  final bool isLogin;
  final String loginLabel;
  final String signupLabel;
  final VoidCallback onLogin;
  final VoidCallback onSignup;
  final bool isDark;

  static const _primary = Color(0xFF1A5F4A);

  const _AuthModeTabs({
    required this.isLogin,
    required this.loginLabel,
    required this.signupLabel,
    required this.onLogin,
    required this.onSignup,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE8E4DE)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabChip(label: loginLabel, selected: isLogin, onTap: onLogin),
          ),
          Expanded(
            child: _TabChip(label: signupLabel, selected: !isLogin, onTap: onSignup),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _primary = Color(0xFF1A5F4A);

  const _TabChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _primary : Colors.transparent,
      borderRadius: BorderRadius.circular(3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(3),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: selected ? Colors.white : _primary,
            ),
          ),
        ),
      ),
    );
  }
}
