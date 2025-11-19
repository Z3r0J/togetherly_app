import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import '../models/magic_link_models.dart';
import '../config/api_config.dart';

class AuthService {
  static String get baseUrl => ApiConfig.authUrl;
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  // Login method
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));

        // Save tokens to shared preferences
        await _saveTokens(
          loginResponse.data.accessToken,
          loginResponse.data.refreshToken,
          loginResponse.data.userId,
        );

        return loginResponse;
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  // Get user data
  Future<User> getUserData() async {
    try {
      final accessToken = await getAccessToken();

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final userResponse = UserResponse.fromJson(jsonDecode(response.body));
        return userResponse.data;
      } else if (response.statusCode == 401) {
        // Token expired, clear tokens
        await clearTokens();
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to get user data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get user error: $e');
    }
  }

  // Save tokens to shared preferences
  Future<void> _saveTokens(
    String accessToken,
    String refreshToken,
    String userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_userIdKey, userId);
  }

  // Get access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Get user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    return accessToken != null;
  }

  // Clear tokens (logout)
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
  }

  // Logout
  Future<void> logout() async {
    await clearTokens();
  }

  // Send magic link to email
  Future<MagicLinkResponse> sendMagicLink(MagicLinkRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/magic-link'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return MagicLinkResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          'Failed to send magic link: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Send magic link error: $e');
    }
  }

  // Save tokens from magic link deep link
  Future<void> saveMagicLinkTokens(
    String accessToken,
    String refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Save tokens using existing key constants
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);

    // Note: userId will be fetched after saving tokens via getUserData()
  }
}
