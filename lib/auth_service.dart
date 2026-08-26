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
  static const String baseUrl = 'https://sunnahsource.org/QRN/api/auth.php';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // ============ SINGLETON ============
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ============ STORAGE METHODS ============

  /// Save authentication token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Save user data
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Get stored user
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data != null) {
      return User.fromJson(jsonDecode(data));
    }
    return null;
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all session data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // ============ HTTP HELPERS ============

  /// Make POST request without authentication
  Future<Map<String, dynamic>> _post(
    String action,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse(baseUrl);
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

  /// Make POST request with authentication
  Future<Map<String, dynamic>> _postWithAuth(
    String action,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final url = Uri.parse(baseUrl);
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
  // AUTHENTICATION API METHODS
  // ============================================================

  // ---------- REGISTER ----------
  /// Register a new user
  /// Returns: { success, message, data: { user_id, email, requires_verification } }
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

  // ---------- VERIFY EMAIL ----------
  /// Verify email with 6-digit code
  /// Returns: { success, message, data: { token, user } }
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
      final userData = result['data']['user'];
      if (token != null) {
        await saveToken(token);
        await saveUser(User.fromJson(userData));
      }
    }
    return result;
  }

  // ---------- RESEND VERIFICATION CODE ----------
  /// Resend verification code to email
  Future<Map<String, dynamic>> resendVerificationCode({
    required String email,
  }) async {
    return _post('resend-code', {'email': email.trim()});
  }

  // ---------- LOGIN ----------
  /// Login with email and password
  /// Returns: { success, message, data: { token, user } }
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await _post('login', {
      'email': email.trim(),
      'password': password,
    });

    // Auto-save session on successful login
    if (result['success'] == true && result['data'] != null) {
      final token = result['data']['token'];
      final userData = result['data']['user'];
      if (token != null) {
        await saveToken(token);
        await saveUser(User.fromJson(userData));
      }
    }
    return result;
  }

  // ---------- GOOGLE LOGIN ----------
  /// Login with Google
  /// Returns: { success, message, data: { token, user } }
  Future<Map<String, dynamic>> loginWithGoogle({
    required String token,
    required String email,
    required String name,
    required String providerId,
  }) async {
    final result = await _post('google', {
      'token': token,
      'email': email.trim(),
      'name': name.trim(),
      'provider_id': providerId,
    });

    // Auto-save session on successful login
    if (result['success'] == true && result['data'] != null) {
      final authToken = result['data']['token'];
      final userData = result['data']['user'];
      if (authToken != null) {
        await saveToken(authToken);
        await saveUser(User.fromJson(userData));
      }
    }
    return result;
  }

  // ---------- APPLE LOGIN ----------
  /// Login with Apple
  /// Returns: { success, message, data: { token, user } }
  Future<Map<String, dynamic>> loginWithApple({
    required String token,
    required String email,
    required String name,
    required String providerId,
  }) async {
    final result = await _post('apple', {
      'token': token,
      'email': email.trim(),
      'name': name.trim(),
      'provider_id': providerId,
    });

    // Auto-save session on successful login
    if (result['success'] == true && result['data'] != null) {
      final authToken = result['data']['token'];
      final userData = result['data']['user'];
      if (authToken != null) {
        await saveToken(authToken);
        await saveUser(User.fromJson(userData));
      }
    }
    return result;
  }

  // ---------- FORGOT PASSWORD ----------
  /// Send password reset code to email
  /// Returns: { success, message }
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    return _post('forgot-password', {'email': email.trim()});
  }

  // ---------- VERIFY RESET CODE ----------
  /// Verify password reset code
  /// Returns: { success, message, data: { reset_id } }
  Future<Map<String, dynamic>> verifyResetCode({
    required String email,
    required String code,
  }) async {
    return _post('verify-reset-code', {
      'email': email.trim(),
      'code': code.trim(),
    });
  }

  // ---------- RESET PASSWORD ----------
  /// Reset password with code
  /// Returns: { success, message }
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

  // ---------- GET PROFILE ----------
  /// Get current user profile (requires authentication)
  /// Returns: { success, message, data: { user } }
  Future<Map<String, dynamic>> getProfile() async {
    return _postWithAuth('get-profile', {});
  }

  // ---------- UPDATE PROFILE ----------
  /// Update user profile (requires authentication)
  /// Returns: { success, message }
  Future<Map<String, dynamic>> updateProfile({required String name}) async {
    final result = await _postWithAuth('update-profile', {'name': name.trim()});

    // Refresh user data if successful
    if (result['success'] == true) {
      final user = await getUser();
      if (user != null) {
        final updatedUser = User(
          id: user.id,
          email: user.email,
          name: name.trim(),
          emailVerified: user.emailVerified,
          authProvider: user.authProvider,
          createdAt: user.createdAt,
        );
        await saveUser(updatedUser);
      }
    }
    return result;
  }

  // ---------- CHANGE PASSWORD ----------
  /// Change user password (requires authentication)
  /// Returns: { success, message }
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return _postWithAuth('change-password', {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }

  // ---------- DELETE ACCOUNT ----------
  /// Delete user account (requires authentication)
  /// Returns: { success, message }
  Future<Map<String, dynamic>> deleteAccount() async {
    final result = await _postWithAuth('delete-account', {});
    if (result['success'] == true) {
      await logout();
    }
    return result;
  }

  // ---------- LOGOUT ----------
  /// Logout user (clear local session)
  Future<void> logoutUser() async {
    await _post('logout', {});
    await logout();
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
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

  /// Get current user (cached)
  Future<User?> getCurrentUser() async {
    return await getUser();
  }

  /// Check if token is valid (ping server)
  Future<bool> isTokenValid() async {
    try {
      final result = await getProfile();
      return result['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
