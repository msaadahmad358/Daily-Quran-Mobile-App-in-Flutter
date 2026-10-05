import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'translations.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import 'theme/app_surfaces.dart';
import 'navigation/app_navigation.dart';
import 'widgets/app_main_drawer.dart';

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
  static const _primary = Color(0xFF1A5F4A);
  static const _primaryLight = Color(0xFF2D7A62);
  static const _pagePadding = EdgeInsets.fromLTRB(20, 8, 20, 28);

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
      backgroundColor: AppSurfaces.scaffold(isDark),
      drawer: const AppMainDrawer(),
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          getText('settings'),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => openAppNotifications(context),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: _primary),
                  const SizedBox(height: 16),
                  Text(
                    getText('pleaseWait'),
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: _pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileCard(isDark, getText),
                  const SizedBox(height: 28),
                  _buildSectionTitle(getText('language'), isDark),
                  const SizedBox(height: 10),
                  _buildSettingsGroup(
                    isDark: isDark,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'English',
                            label: Text('English'),
                          ),
                          ButtonSegment(
                            value: 'French',
                            label: Text('Français'),
                          ),
                        ],
                        selected: {widget.currentLanguage},
                        onSelectionChanged: (s) {
                          widget.onLanguageChange(s.first);
                        },
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          foregroundColor:
                              WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.white;
                            }
                            return isDark ? Colors.grey[300] : Colors.grey[800];
                          }),
                          backgroundColor:
                              WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return _primary;
                            }
                            return Colors.transparent;
                          }),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(getText('readingPreferences'), isDark),
                  const SizedBox(height: 10),
                  _buildSettingsGroup(
                    isDark: isDark,
                    child: Column(
                      children: [
                        _settingsSwitchTile(
                          isDark: isDark,
                          title: getText('showTranslation'),
                          subtitle: getText('showTranslationDesc'),
                          value: _showTranslation,
                          onChanged: (v) {
                            setState(() {
                              _showTranslation = v;
                              _savePreferences();
                            });
                          },
                        ),
                        _groupDivider(isDark),
                        _settingsSwitchTile(
                          isDark: isDark,
                          title: getText('showTafsir'),
                          subtitle: getText('showTafsirDesc'),
                          value: _showTafsir,
                          onChanged: (v) {
                            setState(() {
                              _showTafsir = v;
                              _savePreferences();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(getText('theme'), isDark),
                  const SizedBox(height: 10),
                  _buildSettingsGroup(
                    isDark: isDark,
                    child: _settingsSwitchTile(
                      isDark: isDark,
                      title: widget.isDarkMode
                          ? getText('darkMode')
                          : getText('lightMode'),
                      subtitle: widget.isDarkMode
                          ? getText('switchToLight')
                          : getText('switchToDark'),
                      value: widget.isDarkMode,
                      onChanged: widget.onThemeToggle,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(getText('account'), isDark),
                  const SizedBox(height: 10),
                  if (_currentUser != null) ...[
                    _buildSettingsGroup(
                      isDark: isDark,
                      child: Column(
                        children: [
                          _settingsNavTile(
                            isDark: isDark,
                            icon: Icons.person_outline_rounded,
                            title: getText('editProfile'),
                            onTap: _showEditProfileDialog,
                          ),
                          _groupDivider(isDark),
                          _settingsNavTile(
                            isDark: isDark,
                            icon: Icons.lock_outline_rounded,
                            title: getText('changePassword'),
                            onTap: _showChangePasswordDialog,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsGroup(
                      isDark: isDark,
                      child: Column(
                        children: [
                          _settingsNavTile(
                            isDark: isDark,
                            icon: Icons.logout_rounded,
                            title: getText('logout'),
                            titleColor: Colors.red.shade700,
                            iconColor: Colors.red.shade700,
                            onTap: _logout,
                          ),
                          _groupDivider(isDark),
                          _settingsNavTile(
                            isDark: isDark,
                            icon: Icons.delete_outline_rounded,
                            title: getText('deleteAccount'),
                            titleColor: Colors.red.shade700,
                            iconColor: Colors.red.shade700,
                            onTap: _deleteAccount,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    _buildSettingsGroup(
                      isDark: isDark,
                      child: _settingsNavTile(
                        isDark: isDark,
                        icon: Icons.person_add_alt_1_outlined,
                        title: getText('createAccount'),
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
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        getText('createAccountMessage'),
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Text(
                    '${getText('version')} 1.0.1',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[600] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard(bool isDark, String Function(String) getText) {
    final verified = _currentUser?.emailVerified == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppSurfaces.card(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _primary.withValues(alpha: 0.35)),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: _primary.withValues(alpha: 0.12),
              child: Text(
                _currentUser?.name?.isNotEmpty == true
                    ? _currentUser!.name![0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: _primary,
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
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
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser?.email ?? getText('notSignedIn'),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                if (_currentUser != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (verified ? _primary : Colors.orange)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      verified ? getText('verified') : getText('notVerified'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: verified ? _primary : Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup({
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppSurfaces.card(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _groupDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey[200],
    );
  }

  Widget _settingsSwitchTile({
    required bool isDark,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: _primary,
    );
  }

  Widget _settingsNavTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    final fg = titleColor ?? (isDark ? Colors.white : const Color(0xFF1A1A1A));
    final ic = iconColor ?? _primary;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, color: ic, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
      ),
      onTap: onTap,
    );
  }
}
