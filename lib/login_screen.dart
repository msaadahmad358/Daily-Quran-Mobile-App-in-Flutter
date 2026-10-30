import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qrn_app/theme/app_arabic.dart';
import 'auth_service.dart';
import 'translations.dart';
import 'base_screen.dart';
import 'forgot_password_screen.dart';

/// Countries shown in the signup picker. Belgium & France first.
const List<String> kSignupCountries = [
  'Belgium',
  'France',
  'Netherlands',
  'Germany',
  'Luxembourg',
  'United Kingdom',
  'Spain',
  'Italy',
  'Switzerland',
  'Austria',
  'Sweden',
  'Norway',
  'Denmark',
  'Ireland',
  'Portugal',
  'Poland',
  'Morocco',
  'Algeria',
  'Tunisia',
  'Egypt',
  'Turkey',
  'Saudi Arabia',
  'United Arab Emirates',
  'Qatar',
  'Kuwait',
  'Jordan',
  'Pakistan',
  'India',
  'Bangladesh',
  'Indonesia',
  'Malaysia',
  'Nigeria',
  'Senegal',
  'Somalia',
  'United States',
  'Canada',
  'Australia',
  'Other',
];

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

class _LoginScreenState extends BaseScreenState<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFF1A5F4A);
  static const _primaryDark = Color(0xFF0E3B2E);
  static const _accent = Color(0xFF2D7A62);
  static const _gold = Color(0xFFC9A96E);

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _country;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  final AuthService _auth = AuthService();

  String _t(String key) => Translations.getText(widget.currentLanguage, key);

  String _api(Object? message, String fallbackKey) => Translations.apiMessage(
      widget.currentLanguage, message,
      fallbackKey: fallbackKey);

  InputDecoration _field({
    required String label,
    required IconData icon,
    required bool isDark,
    Widget? suffix,
  }) {
    final fill = isDark ? const Color(0xFF1B2623) : const Color(0xFFF7F5F1);
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.grey[400] : Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: _accent,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 10, right: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _primary.withValues(alpha: isDark ? 0.35 : 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: isDark ? _gold : _primary),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 52),
      suffixIcon: suffix,
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? Colors.white10 : const Color(0xFFE9E4DA),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _gold, width: 1.6),
      ),
    );
  }

  Widget _staggered(int index, Widget child) {
    final start = (0.15 + index * 0.08).clamp(0.0, 0.9);
    final anim = CurvedAnimation(
      parent: _intro,
      curve: Interval(start, math.min(start + 0.45, 1.0),
          curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final canPop = Navigator.canPop(context);
    final cardColor = isDark ? const Color(0xFF121A18) : Colors.white;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_accent, _primary, _primaryDark],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _IslamicPatternPainter()),
            ),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        if (canPop)
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white, size: 20),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 22),
                          _staggered(
                            1,
                            Container(
                              padding:
                                  const EdgeInsets.fromLTRB(18, 18, 18, 22),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: _gold.withValues(alpha: 0.35),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 30,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _ModeSwitch(
                                    isLogin: _isLogin,
                                    loginLabel: _t('login'),
                                    signupLabel: _t('signup'),
                                    isDark: isDark,
                                    onChanged: (v) => setState(() {
                                      _isLogin = v;
                                    }),
                                  ),
                                  const SizedBox(height: 20),
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 320),
                                    curve: Curves.easeOutCubic,
                                    alignment: Alignment.topCenter,
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      transitionBuilder: (child, a) =>
                                          FadeTransition(
                                        opacity: a,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.05, 0),
                                            end: Offset.zero,
                                          ).animate(a),
                                          child: child,
                                        ),
                                      ),
                                      child: _buildForm(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          _staggered(
                            3,
                            Text(
                              'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                              style: AppArabic.style(
                                fontSize: 20,
                                color: _gold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _staggered(
                            4,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_rounded,
                                    size: 14,
                                    color:
                                        Colors.white.withValues(alpha: 0.7)),
                                const SizedBox(width: 6),
                                Text(
                                  _t('authPrivacyNote'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return _staggered(
      0,
      Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFE8D3A2), _gold, Color(0xFF9C7A3C)],
              ),
              boxShadow: [
                BoxShadow(
                  color: _gold.withValues(alpha: 0.45),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Container(
              width: 124,
              height: 124,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.menu_book_rounded,
                    color: _primary,
                    size: 60,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _t('appTitleShort'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _isLogin ? _t('authWelcomeBack') : _t('authCreateAccount'),
              key: ValueKey(_isLogin),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isDark) {
    final textStyle = TextStyle(
      color: isDark ? Colors.white : Colors.black87,
      fontSize: 15.5,
    );
    const gap = SizedBox(height: 14);
    return Column(
      key: ValueKey(_isLogin),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_isLogin) ...[
          TextField(
            controller: _nameController,
            style: textStyle,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: _field(
              label: _t('fullName'),
              icon: Icons.person_outline_rounded,
              isDark: isDark,
            ),
          ),
          gap,
        ],
        TextField(
          controller: _emailController,
          style: textStyle,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          decoration: _field(
            label: _t('email'),
            icon: Icons.alternate_email_rounded,
            isDark: isDark,
          ),
        ),
        if (!_isLogin) ...[
          gap,
          DropdownButtonFormField<String>(
            initialValue: _country,
            isExpanded: true,
            menuMaxHeight: 360,
            borderRadius: BorderRadius.circular(16),
            dropdownColor: isDark ? const Color(0xFF1B2623) : Colors.white,
            style: textStyle,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _gold),
            decoration: _field(
              label: _t('country'),
              icon: Icons.public_rounded,
              isDark: isDark,
            ),
            items: [
              for (final c in kSignupCountries)
                DropdownMenuItem(
                  value: c,
                  child: Text(
                    c == 'Belgium'
                        ? '🇧🇪  ${Translations.countryName(widget.currentLanguage, c)}'
                        : c == 'France'
                            ? '🇫🇷  ${Translations.countryName(widget.currentLanguage, c)}'
                            : Translations.countryName(widget.currentLanguage, c),
                  ),
                ),
            ],
            onChanged: (v) => setState(() => _country = v),
          ),
        ],
        gap,
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: textStyle,
          textInputAction:
              _isLogin ? TextInputAction.done : TextInputAction.next,
          onSubmitted: (_) {
            if (_isLogin) _submit();
          },
          decoration: _field(
            label: _t('password'),
            icon: Icons.lock_outline_rounded,
            isDark: isDark,
            suffix: _eye(_obscurePassword, isDark,
                () => setState(() => _obscurePassword = !_obscurePassword)),
          ),
        ),
        if (!_isLogin) ...[
          gap,
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            style: textStyle,
            onSubmitted: (_) => _submit(),
            decoration: _field(
              label: _t('confirmPassword'),
              icon: Icons.verified_user_outlined,
              isDark: isDark,
              suffix: _eye(_obscureConfirm, isDark,
                  () => setState(() => _obscureConfirm = !_obscureConfirm)),
            ),
          ),
        ],
        if (_isLogin)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _openForgot,
              child: Text(
                _t('forgotPassword'),
                style: TextStyle(
                  color: isDark ? _gold : _primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        else
          const SizedBox(height: 18),
        const SizedBox(height: 4),
        _GradientButton(
          loading: _isLoading,
          label: _isLogin ? _t('login') : _t('signup'),
          icon: _isLogin ? Icons.login_rounded : Icons.person_add_alt_1_rounded,
          onPressed: _isLoading ? null : _submit,
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLogin ? _t('authNoAccount') : _t('authHaveAccount'),
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(
                _isLogin ? _t('signup') : _t('login'),
                style: TextStyle(
                  color: isDark ? _gold : _primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _eye(bool obscure, bool isDark, VoidCallback onTap) => IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        onPressed: onTap,
      );

  void _openForgot() {
    widget.onForgotPassword();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(
          isDarkMode: widget.isDarkMode,
          currentLanguage: widget.currentLanguage,
          initialEmail: _emailController.text.trim(),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError(_t('pleaseFillAllFields'));
      return;
    }

    if (!_isLogin) {
      if (_nameController.text.trim().isEmpty) {
        _showError(_t('nameCannotBeEmpty'));
        return;
      }
      if (_country == null) {
        _showError(_t('selectCountry'));
        return;
      }
      if (password.length < 6) {
        _showError(_t('passwordMin6'));
        return;
      }
      if (password != _confirmPasswordController.text) {
        _showError(_t('passwordsMismatch'));
        return;
      }
    }

    setState(() => _isLoading = true);
    final result = _isLogin
        ? await _auth.login(email: email, password: password)
        : await _auth.register(
            email: email,
            password: password,
            name: _nameController.text.trim(),
            country: _country!,
            confirmPassword: _confirmPasswordController.text,
          );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (!_isLogin) {
        _showSuccess(_api(result['message'], 'registrationSuccess'));
      }
      widget.onLogin();
      if (!mounted) return;
      // Only navigate if the caller didn't already close this screen.
      if (ModalRoute.of(context)?.isCurrent ?? true) {
        final nav = Navigator.of(context);
        if (nav.canPop()) {
          nav.pop();
        } else {
          // Login screen is the root (e.g. after logout): go to home.
          nav.pushNamedAndRemoveUntil('/', (_) => false);
        }
      }
    } else {
      _showError(_api(result['message'],
          _isLogin ? 'loginFailed' : 'registrationFailed'));
    }
  }

  void _showError(String message) => _snack(message, Colors.red.shade700,
      Icons.error_outline_rounded);

  void _showSuccess(String message) =>
      _snack(message, _primary, Icons.check_circle_outline_rounded);

  void _snack(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

class _ModeSwitch extends StatelessWidget {
  final bool isLogin;
  final String loginLabel;
  final String signupLabel;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ModeSwitch({
    required this.isLogin,
    required this.loginLabel,
    required this.signupLabel,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2623) : const Color(0xFFF1EDE5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: isLogin ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D7A62), Color(0xFF1A5F4A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1A5F4A).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              _label(loginLabel, isLogin, () => onChanged(true)),
              _label(signupLabel, !isLogin, () => onChanged(false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String text, bool selected, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.grey[400]! : const Color(0xFF1A5F4A)),
              ),
              child: Text(text),
            ),
          ),
        ),
      );
}

class _GradientButton extends StatelessWidget {
  final bool loading;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _GradientButton({
    required this.loading,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: onPressed == null && !loading ? 0.6 : 1,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF2D7A62), Color(0xFF1A5F4A), Color(0xFF0E3B2E)],
          ),
          border: Border.all(color: const Color(0x66C9A96E)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A5F4A).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPressed,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Subtle 8-point star (Rub el Hizb) lattice in the background.
class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFC9A96E).withValues(alpha: 0.10);
    const step = 64.0;
    const r = 18.0;
    for (double y = 0; y < size.height + step; y += step) {
      for (double x = 0; x < size.width + step; x += step) {
        final dx = ((y / step).round().isOdd) ? x + step / 2 : x;
        final c = Offset(dx, y);
        canvas.drawRect(Rect.fromCenter(center: c, width: r, height: r), paint);
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(math.pi / 4);
        canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: r, height: r), paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
