import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'translations.dart';
import 'auth_service.dart';
import 'login_screen.dart';

class SettingsTab extends StatefulWidget {
  final Function(bool) onThemeToggle;
  final Function(String) onLanguageChange;
  final String currentLanguage;
  final bool isDarkMode;
  final VoidCallback? onUserUpdated; // ← ADD

  const SettingsTab({
    super.key,
    required this.onThemeToggle,
    required this.onLanguageChange,
    required this.currentLanguage,
    required this.isDarkMode,
    this.onUserUpdated, // ← ADD
  });

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final AuthService _auth = AuthService();
  User? _currentUser;
  bool _showTranslation = true;
  bool _showTafsir = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadPreferences();
  }

  void _loadUser() async {
    final user = await _auth.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showTranslation = prefs.getBool('show_translation') ?? true;
      _showTafsir = prefs.getBool('show_tafsir') ?? true;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_translation', _showTranslation);
    await prefs.setBool('show_tafsir', _showTafsir);
  }

  void _showEditProfileDialog() {
    final TextEditingController nameController = TextEditingController(
      text: _currentUser?.name ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          Translations.getText(widget.currentLanguage, 'editProfile'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: Translations.getText(
                  widget.currentLanguage,
                  'fullName',
                ),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Translations.getText(widget.currentLanguage, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      Translations.getText(
                        widget.currentLanguage,
                        'nameCannotBeEmpty',
                      ),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              setState(() => _isLoading = true);
              final result = await _auth.updateProfile(name: name);
              setState(() => _isLoading = false);
              if (result['success'] == true) {
                _loadUser();
                widget.onUserUpdated?.call(); // ← ADD: refresh top banner

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      Translations.getText(
                        widget.currentLanguage,
                        'profileUpdated',
                      ),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['message'] ??
                          Translations.getText(
                            widget.currentLanguage,
                            'failedUpdateProfile',
                          ),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A5F4A),
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    Translations.getText(widget.currentLanguage, 'save'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController oldPassController = TextEditingController();
    final TextEditingController newPassController = TextEditingController();
    final TextEditingController confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          Translations.getText(widget.currentLanguage, 'changePassword'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: Translations.getText(
                  widget.currentLanguage,
                  'currentPassword',
                ),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: Translations.getText(
                  widget.currentLanguage,
                  'newPassword',
                ),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPassController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: Translations.getText(
                  widget.currentLanguage,
                  'confirmNewPassword',
                ),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Translations.getText(widget.currentLanguage, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final oldPass = oldPassController.text;
              final newPass = newPassController.text;
              final confirmPass = confirmPassController.text;

              if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      Translations.getText(
                        widget.currentLanguage,
                        'pleaseFillAllFields',
                      ),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (newPass != confirmPass) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      Translations.getText(
                        widget.currentLanguage,
                        'passwordsDoNotMatch',
                      ),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (newPass.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      Translations.getText(
                        widget.currentLanguage,
                        'passwordMinLength',
                      ),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setState(() => _isLoading = true);
              final result = await _auth.changePassword(
                oldPassword: oldPass,
                newPassword: newPass,
              );
              setState(() => _isLoading = false);

              if (result['success'] == true) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      Translations.getText(
                        widget.currentLanguage,
                        'passwordChanged',
                      ),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['message'] ??
                          Translations.getText(
                            widget.currentLanguage,
                            'failedChangePassword',
                          ),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A5F4A),
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(Translations.getText(widget.currentLanguage, 'update')),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.getText(widget.currentLanguage, 'logout')),
        content: Text(
          Translations.getText(widget.currentLanguage, 'confirmLogout'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(Translations.getText(widget.currentLanguage, 'cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(Translations.getText(widget.currentLanguage, 'logout')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      await _auth.logoutUser();
      setState(() => _isLoading = false);

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(
              onLogin: () {},
              onSignup: () {},
              onForgotPassword: () {},
              currentLanguage: widget.currentLanguage,
              isDarkMode: widget.isDarkMode,
              onSkipLogin: () {},
            ),
          ),
          (route) => false,
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          Translations.getText(widget.currentLanguage, 'deleteAccount'),
          style: const TextStyle(color: Colors.red),
        ),
        content: Text(
          Translations.getText(widget.currentLanguage, 'deleteAccountConfirm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(Translations.getText(widget.currentLanguage, 'cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(Translations.getText(widget.currentLanguage, 'delete')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final result = await _auth.deleteAccount();
      setState(() => _isLoading = false);

      if (result['success'] == true) {
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(
                onLogin: () {},
                onSignup: () {},
                onForgotPassword: () {},
                currentLanguage: widget.currentLanguage,
                isDarkMode: widget.isDarkMode,
                onSkipLogin: () {},
              ),
            ),
            (route) => false,
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to delete account'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final getText = (String key) =>
        Translations.getText(widget.currentLanguage, key);
    final isDark = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0A)
          : const Color(0xFFF5F0EB),
      appBar: AppBar(
        title: Text(
          getText('settings'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: isDark
            ? const Color(0xFF0A0A0A)
            : const Color(0xFFF5F0EB),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    Translations.getText(widget.currentLanguage, 'pleaseWait'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                            : [Colors.white, const Color(0xFFF8F5F0)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A5F4A), Color(0xFF2D7A62)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _currentUser?.name?.isNotEmpty == true
                                  ? _currentUser!.name![0].toUpperCase()
                                  : '👤',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentUser?.name ?? getText('guestUser'),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                _currentUser?.email ?? getText('notSignedIn'),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _currentUser?.emailVerified == true
                                      ? Colors.green.withValues(alpha: 0.15)
                                      : Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _currentUser?.emailVerified == true
                                      ? getText('verified')
                                      : getText('notVerified'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _currentUser?.emailVerified == true
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Language Section
                  _buildSectionHeader('🌐', getText('language'), isDark),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _buildCardDecoration(isDark),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => widget.onLanguageChange('English'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: widget.currentLanguage == 'English'
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF1A5F4A),
                                          Color(0xFF2D7A62),
                                        ],
                                      )
                                    : null,
                                color: widget.currentLanguage == 'English'
                                    ? null
                                    : (isDark
                                          ? const Color(0xFF3D3D3D)
                                          : const Color(0xFFF0F0F0)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'English',
                                  style: TextStyle(
                                    color: widget.currentLanguage == 'English'
                                        ? Colors.white
                                        : (isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[700]),
                                    fontWeight:
                                        widget.currentLanguage == 'English'
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => widget.onLanguageChange('French'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: widget.currentLanguage == 'French'
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF1A5F4A),
                                          Color(0xFF2D7A62),
                                        ],
                                      )
                                    : null,
                                color: widget.currentLanguage == 'French'
                                    ? null
                                    : (isDark
                                          ? const Color(0xFF3D3D3D)
                                          : const Color(0xFFF0F0F0)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Français',
                                  style: TextStyle(
                                    color: widget.currentLanguage == 'French'
                                        ? Colors.white
                                        : (isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[700]),
                                    fontWeight:
                                        widget.currentLanguage == 'French'
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Reading Preferences
                  _buildSectionHeader(
                    '📖',
                    getText('readingPreferences'),
                    isDark,
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _buildCardDecoration(isDark),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1A5F4A,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.translate,
                                color: Color(0xFF1A5F4A),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getText('showTranslation'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  getText('showTranslationDesc'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: _showTranslation,
                          onChanged: (value) {
                            setState(() {
                              _showTranslation = value;
                              _savePreferences();
                            });
                          },
                          activeColor: const Color(0xFF1A5F4A),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _buildCardDecoration(isDark),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFC9A96E,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                color: Color(0xFFC9A96E),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getText('showTafsir'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  getText('showTafsirDesc'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: _showTafsir,
                          onChanged: (value) {
                            setState(() {
                              _showTafsir = value;
                              _savePreferences();
                            });
                          },
                          activeColor: const Color(0xFF1A5F4A),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Theme Section
                  _buildSectionHeader('🎨', getText('theme'), isDark),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _buildCardDecoration(isDark),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF1A5F4A,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                widget.isDarkMode
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                                color: const Color(0xFF1A5F4A),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.isDarkMode
                                      ? getText('darkMode')
                                      : getText('lightMode'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  widget.isDarkMode
                                      ? getText('switchToLight')
                                      : getText('switchToDark'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: widget.isDarkMode,
                          onChanged: widget.onThemeToggle,
                          activeColor: const Color(0xFF1A5F4A),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Account Section
                  _buildSectionHeader('🔐', getText('account'), isDark),
                  const SizedBox(height: 12),

                  if (_currentUser != null) ...[
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: getText('editProfile'),
                      isDark: isDark,
                      onTap: _showEditProfileDialog,
                    ),
                    const SizedBox(height: 8),

                    _buildMenuItem(
                      icon: Icons.lock_outline,
                      title: getText('changePassword'),
                      isDark: isDark,
                      onTap: _showChangePasswordDialog,
                    ),
                    const SizedBox(height: 8),

                    _buildMenuItem(
                      icon: Icons.logout,
                      title: getText('logout'),
                      isDark: isDark,
                      iconColor: Colors.red,
                      onTap: _logout,
                    ),
                    const SizedBox(height: 8),

                    _buildMenuItem(
                      icon: Icons.delete_outline,
                      title: getText('deleteAccount'),
                      isDark: isDark,
                      iconColor: Colors.red,
                      onTap: _deleteAccount,
                    ),
                  ] else ...[
                    _buildMenuItem(
                      icon: Icons.person_add_outlined,
                      title: getText('createAccount'),
                      isDark: isDark,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(
                              onLogin: () {
                                Navigator.of(context).pop();
                                widget.onUserUpdated?.call();
                                _loadUser();
                              },
                              onSignup: () {
                                Navigator.of(context).pop();
                                widget.onUserUpdated?.call();
                                _loadUser();
                              },
                              onForgotPassword: () {},
                              onSkipLogin: () {
                                Navigator.of(context).pop();
                              },
                              currentLanguage: widget.currentLanguage,
                              isDarkMode: isDark,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2A2A2A)
                            : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        getText('createAccountMessage'),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Version
                  Center(
                    child: Text(
                      '${getText('version')} 1.0.1',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String emoji, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildCardDecoration(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
            : [Colors.white, const Color(0xFFF8F5F0)],
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                : [Colors.white, const Color(0xFFF8F5F0)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? const Color(0xFF1A5F4A), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
