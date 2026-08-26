import 'package:flutter/material.dart';
import 'package:qrn_app/main.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;
  final VoidCallback onSignup;
  final VoidCallback onForgotPassword;
  final String currentLanguage;
  final bool isDarkMode;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onSignup,
    required this.onForgotPassword,
    required this.currentLanguage,
    required this.isDarkMode,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final getText = (String key) =>
        AppTranslations.getText(widget.currentLanguage, key);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F5F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Back Button
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark ? Colors.white : const Color(0xFF1A5F4A),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                _isLogin ? getText('login') : getText('signup'),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A5F4A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isLogin ? '${getText('welcome')} 👋' : getText('welcomeDesc'),
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),

              // ========== VERIFICATION SCREEN ==========
              if (_showVerification) ...[
                Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A5F4A),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter the 6-digit code sent to $_verificationEmail',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 30),

                // Code Input
                TextField(
                  controller: _codeController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Verification Code',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    prefixIcon: Icon(Icons.pin, color: const Color(0xFF1A5F4A)),
                    counterText: '',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF1A5F4A),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A5F4A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Verify',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _resendCode,
                  child: Text(
                    'Resend Code',
                    style: TextStyle(
                      color: const Color(0xFF1A5F4A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _showVerification = false),
                  child: Text(
                    'Back to Login',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
              ] else ...[
                // ========== EMAIL INPUT ==========
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: getText('email'),
                    labelStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: const Color(0xFF1A5F4A),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF1A5F4A),
                        width: 2,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Name (Signup only)
                if (!_isLogin) ...[
                  TextField(
                    controller: _nameController,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: const Color(0xFF1A5F4A),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF1A5F4A),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Password
                TextField(
                  controller: _passwordController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: getText('password'),
                    labelStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: const Color(0xFF1A5F4A),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF1A5F4A),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                // Forgot Password (Login only)
                if (_isLogin) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: widget.onForgotPassword,
                      child: Text(
                        getText('forgotPassword'),
                        style: const TextStyle(
                          color: Color(0xFF1A5F4A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A5F4A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            _isLogin ? getText('login') : getText('signup'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Toggle Login/Signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin
                          ? getText('dontHaveAccount')
                          : getText('alreadyHaveAccount'),
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(
                        _isLogin ? getText('signup') : getText('login'),
                        style: const TextStyle(
                          color: Color(0xFF1A5F4A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        getText('orContinueWith'),
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Social Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildSocialButton(
                        Icons.g_mobiledata,
                        getText('google'),
                        isDark,
                        _loginWithGoogle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSocialButton(
                        Icons.apple,
                        getText('apple'),
                        isDark,
                        _loginWithApple,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ========== SUBMIT HANDLERS ==========

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isLogin) {
      // LOGIN
      final result = await _auth.login(email: email, password: password);

      if (result['success'] == true) {
        widget.onLogin();
      } else {
        // Check if verification required
        if (result['data'] != null &&
            result['data']['requires_verification'] == true) {
          setState(() {
            _verificationEmail = email;
            _showVerification = true;
            _isLoading = false;
          });
          return;
        }
        _showError(result['message'] ?? 'Login failed');
      }
    } else {
      // REGISTER
      final name = _nameController.text.trim();

      if (name.isEmpty) {
        _showError('Full name is required');
        setState(() => _isLoading = false);
        return;
      }

      final result = await _auth.register(
        email: email,
        password: password,
        name: name,
      );

      if (result['success'] == true) {
        setState(() {
          _verificationEmail = email;
          _showVerification = true;
          _isLoading = false;
        });
        _showSuccess('Verification code sent to your email!');
      } else {
        _showError(result['message'] ?? 'Registration failed');
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _verifyEmail() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      _showError('Please enter the 6-digit verification code');
      return;
    }

    setState(() => _isLoading = true);

    final result = await _auth.verifyEmail(
      email: _verificationEmail,
      code: code,
    );

    if (result['success'] == true) {
      widget.onLogin();
    } else {
      _showError(result['message'] ?? 'Verification failed');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _resendCode() async {
    setState(() => _isLoading = true);

    final result = await _auth.resendVerificationCode(
      email: _verificationEmail,
    );

    if (result['success'] == true) {
      _showSuccess('New code sent to your email!');
    } else {
      _showError(result['message'] ?? 'Failed to resend code');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    // TODO: Implement Google Sign-In
    // For now, demo login
    final result = await _auth.loginWithGoogle(
      token: 'google_token_demo',
      email: 'google_user@example.com',
      name: 'Google User',
      providerId: 'google_123',
    );

    if (result['success'] == true) {
      widget.onLogin();
    } else {
      _showError(result['message'] ?? 'Google login failed');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loginWithApple() async {
    setState(() => _isLoading = true);

    // TODO: Implement Apple Sign-In
    final result = await _auth.loginWithApple(
      token: 'apple_token_demo',
      email: 'apple_user@example.com',
      name: 'Apple User',
      providerId: 'apple_123',
    );

    if (result['success'] == true) {
      widget.onLogin();
    } else {
      _showError(result['message'] ?? 'Apple login failed');
    }

    setState(() => _isLoading = false);
  }

  // ========== UI HELPERS ==========

  Widget _buildSocialButton(
    IconData icon,
    String label,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isDark ? Colors.white : Colors.black, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
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
