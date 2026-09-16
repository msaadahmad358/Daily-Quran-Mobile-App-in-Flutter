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
  final bool emailVerified;
  final String? authProvider;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    this.name,
    required this.emailVerified,
    this.authProvider,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? json['full_name'] ?? '',
      emailVerified: json['email_verified'] ?? false,
      authProvider: json['auth_provider'] ?? 'email',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
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
  // Auth operations (register, login, verify, password reset) live here:
  static const String authUrl = 'https://sunnahsource.org/QRN/api/auth.php';

  // Profile operations (get/update profile, change password, delete) live here:
  static const String userUrl = 'https://sunnahsource.org/QRN/api/user.php';

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

  // ============ HTTP HELPERS ============

  /// POST without auth → defaults to auth.php
  Future<Map<String, dynamic>> _post(
    String action,
    Map<String, dynamic> data, {
    String? endpoint,
  }) async {
    try {
      final url = Uri.parse(endpoint ?? authUrl);
      final body = {'action': action, ...data};

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// POST with auth → defaults to user.php (profile ops live there)
  Future<Map<String, dynamic>> _postWithAuth(
    String action,
    Map<String, dynamic> data, {
    String? endpoint,
  }) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final url = Uri.parse(endpoint ?? userUrl);
      final body = {'action': action, ...data};

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ============================================================
  // AUTH API METHODS (auth.php)
  // ============================================================

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    return _post('register', {
      'email': email.trim(),
      'password': password,
      'name': name.trim(),
    });
  }

  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    final result = await _post('verify-email', {
      'email': email.trim(),
      'code': code.trim(),
    });

    // Auto-login on successful verification
    if (result['success'] == true && result['data'] != null) {
      final token = result['data']['token'];
      if (token != null) {
        await saveToken(token);

        // Try saving user from response, but the response may lack name —
        // fall back to fetching full profile from user.php
        final userData = result['data']['user'];
        if (userData != null) {
          await saveUser(User.fromJson(userData));
        }
        // Always fetch fresh profile to get complete info (name, verified, etc.)
        await getProfile();
      }
    }
    return result;
  }

  Future<Map<String, dynamic>> resendVerificationCode({
    required String email,
  }) async {
    return _post('resend-code', {'email': email.trim()});
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await _post('login', {
      'email': email.trim(),
      'password': password,
    });

    if (result['success'] == true && result['data'] != null) {
      final token = result['data']['token'];
      final userData = result['data']['user'];
      if (token != null) {
        await saveToken(token);
        if (userData != null) {
          await saveUser(User.fromJson(userData));
        }
      }
    }
    return result;
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    return _post('forgot-password', {'email': email.trim()});
  }

  Future<Map<String, dynamic>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    return _post('verify-reset-code', {
      'email': email.trim(),
      'code': code.trim(),
    });
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    return _post('reset-password', {
      'email': email.trim(),
      'code': code.trim(),
      'new_password': newPassword,
    });
  }

  Future<void> logoutUser() async {
    await _post('logout', {});
    await logout();
  }

  // ============================================================
  // USER API METHODS (user.php) — go through _postWithAuth
  // ============================================================

  /// Get profile from user.php and refresh cached user
  Future<Map<String, dynamic>> getProfile() async {
    final result = await _postWithAuth('get-profile', {});

    if (result['success'] == true && result['data'] != null) {
      final userData = result['data']['user'];
      if (userData != null) {
        await saveUser(User.fromJson(userData));
      }
    }
    return result;
  }

  /// Update profile via user.php
  Future<Map<String, dynamic>> updateProfile({required String name}) async {
    final result = await _postWithAuth('update-profile', {'name': name.trim()});

    if (result['success'] == true) {
      // Refresh from server to get authoritative data
      await getProfile();
    }
    return result;
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return _postWithAuth('change-password', {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    final result = await _postWithAuth('delete-account', {});
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
