import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// USER MODEL
// ============================================================
class User {
  final int id;
  final String email;
  final String? name;
  final String? country;
  final bool emailVerified;
  final String? authProvider;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.country,
    required this.emailVerified,
    this.authProvider,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? json['full_name'] ?? '',
      country: json['country'] ?? '',
      emailVerified: json['email_verified'] ?? false,
      authProvider: json['auth_provider'] ?? 'email',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse('${json['created_at']}')
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'country': country,
      'email_verified': emailVerified,
      'auth_provider': authProvider,
    };
  }
}

// ============================================================
// AUTH SERVICE - COMPLETE
// ============================================================
class AuthService {
  // ============ API CONFIGURATION ============
  // Daily Quran backend (register / login / forgot password / donate)
  static const String dqBaseUrl =
      'https://tushroomsinternetlab.sunnahsource.org/daily-quran-app';

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // ============ SINGLETON ============
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ============ STORAGE METHODS ============

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data != null) {
      return User.fromJson(jsonDecode(data));
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  static const Duration _timeout = Duration(seconds: 20);

  static String _netMsg(Object e) => e is TimeoutException
      ? 'Request timed out. Please check your internet and try again.'
      : 'Network error. Please check your internet and try again.';

  // ============ HTTP HELPERS ============

  /// JSON POST to the Daily Quran backend. Returns the decoded body for any
  /// status code (the API always replies with {success, message, ...}).
  Future<Map<String, dynamic>> _dqPost(
    String file,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$dqBaseUrl/$file'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(_timeout);
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
      return {
        'success': false,
        'message': 'Server error: ${response.statusCode}',
      };
    } catch (e) {
      return {'success': false, 'message': _netMsg(e)};
    }
  }

  Future<void> _saveDqSession(Map<String, dynamic> result) async {
    final userData = result['user'];
    if (result['success'] == true && userData is Map<String, dynamic>) {
      final user = User.fromJson({...userData, 'email_verified': true});
      final token = result['token'];
      if (token is String && token.isNotEmpty) await saveToken(token);
      await saveUser(user);
    }
  }

  /// Donate page URL, prefilled with the logged-in user's details.
  Future<Uri> donateUri([String? language]) async {
    final user = await getUser();
    final params = <String, String>{};
    if (language != null) {
      params['lang'] = language == 'English' ? 'en' : 'fr';
    }
    if (user != null) {
      if ((user.name ?? '').isNotEmpty) params['name'] = user.name!;
      params['email'] = user.email;
      params['user_id'] = '${user.id}';
    }
    return Uri.parse(
      '$dqBaseUrl/donate.php',
    ).replace(queryParameters: params.isEmpty ? null : params);
  }

  /// Authenticated JSON POST (Bearer token) to the Daily Quran backend.
  Future<Map<String, dynamic>> _dqAuthPost(
    String file,
    Map<String, dynamic> data,
  ) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    try {
      final response = await http.post(
        Uri.parse('$dqBaseUrl/$file'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      ).timeout(_timeout);
      Map<String, dynamic>? decoded;
      try {
        final d = jsonDecode(response.body);
        if (d is Map<String, dynamic>) decoded = d;
      } catch (_) {}
      if (response.statusCode == 401 &&
          !file.startsWith('change_password') &&
          !file.startsWith('delete_account')) {
        await logout();
        return decoded ??
            {'success': false, 'message': 'Session expired. Please login again.'};
      }
      return decoded ??
          {'success': false, 'message': 'Server error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': _netMsg(e)};
    }
  }

  // ============================================================
  // AUTH API METHODS (Daily Quran backend)
  // ============================================================

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    String country = '',
    String? confirmPassword,
  }) async {
    final result = await _dqPost('register.php', {
      'name': name.trim(),
      'country': country.trim(),
      'email': email.trim(),
      'password': password,
      'confirm_password': confirmPassword ?? password,
    });
    await _saveDqSession(result);
    return result;
  }

  /// Email verification is not used by the new backend (signup logs in).
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    return {'success': false, 'message': 'Email verification is not required'};
  }

  Future<Map<String, dynamic>> resendVerificationCode({
    required String email,
  }) async {
    return {'success': false, 'message': 'Email verification is not required'};
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await _dqPost('login.php', {
      'email': email.trim(),
      'password': password,
    });
    await _saveDqSession(result);
    return result;
  }

  /// Step 1 of forgot password: checks whether an account exists for [email].
  Future<Map<String, dynamic>> checkEmail({required String email}) =>
      _dqPost('check_email.php', {'email': email.trim().toLowerCase()});

  /// Kept for compatibility; same as [checkEmail].
  Future<Map<String, dynamic>> forgotPassword({String email = ''}) =>
      checkEmail(email: email);

  /// Step 2: sets a new password for [email] (no code).
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
    String? confirmPassword,
  }) =>
      _dqPost('reset_password.php', {
        'email': email.trim().toLowerCase(),
        'new_password': newPassword,
        'confirm_password': confirmPassword ?? newPassword,
      });

  /// The logged-in user's payment history (paid / failed / cancelled).
  Future<Map<String, dynamic>> myPayments() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Not authenticated'};
    }
    try {
      final r = await http.get(
        Uri.parse('$dqBaseUrl/my_payments.php'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      ).timeout(_timeout);
      final d = jsonDecode(r.body);
      if (d is Map<String, dynamic>) return d;
    } catch (e) {
      return {'success': false, 'message': _netMsg(e)};
    }
    return {'success': false, 'message': 'Server error'};
  }

  Future<void> logoutUser() async {
    try {
      await _dqAuthPost('logout.php', {});
    } catch (_) {}
    await logout();
  }

  // ============================================================
  // PROFILE METHODS (Bearer token)
  // ============================================================

  Future<Map<String, dynamic>> getProfile() async {
    final result = await _dqAuthPost('profile.php', {});
    final userData = result['user'];
    if (result['success'] == true && userData is Map<String, dynamic>) {
      await saveUser(User.fromJson({...userData, 'email_verified': true}));
    }
    return result;
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? country,
    String? email,
  }) async {
    final body = <String, dynamic>{'name': name.trim()};
    if (country != null) body['country'] = country.trim();
    if (email != null && email.trim().isNotEmpty) body['email'] = email.trim();
    final result = await _dqAuthPost('update_profile.php', body);
    final userData = result['user'];
    if (result['success'] == true && userData is Map<String, dynamic>) {
      await saveUser(User.fromJson({...userData, 'email_verified': true}));
    }
    return result;
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    String? confirmPassword,
  }) async {
    final result = await _dqAuthPost('change_password.php', {
      'current_password': oldPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword ?? newPassword,
    });
    final token = result['token'];
    if (result['success'] == true && token is String && token.isNotEmpty) {
      await saveToken(token);
    }
    return result;
  }

  Future<Map<String, dynamic>> deleteAccount({required String password}) async {
    final result = await _dqAuthPost('delete_account.php', {
      'password': password,
    });
    if (result['success'] == true) {
      await logout();
    }
    return result;
  }
  // ============================================================
  // UTILITY METHODS
  // ============================================================

  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  String? validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  Future<User?> getCurrentUser() async {
    return await getUser();
  }

  Future<bool> isTokenValid() async {
    try {
      final result = await getProfile();
      return result['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
