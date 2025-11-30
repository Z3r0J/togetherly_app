import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import '../models/magic_link_models.dart';
import '../models/register_models.dart';
import '../models/api_error.dart';
import '../config/api_config.dart';

class AuthService {
  static String get baseUrl => ApiConfig.authUrl;
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  // Login method
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(responseBody);

        // Save tokens to shared preferences
        await _saveTokens(
          loginResponse.data.accessToken,
          loginResponse.data.refreshToken,
          loginResponse.data.userId,
        );

        return loginResponse;
      } else {
        // Parsear error del backend
        if (ApiError.isErrorResponse(responseBody)) {
          throw ApiError.fromJson(
            responseBody,
            statusCode: response.statusCode,
          );
        } else {
          throw ApiError.unknownError('Login failed: ${response.statusCode}');
        }
      }
    } on SocketException {
      throw ApiError.networkError();
    } on TimeoutException {
      throw ApiError.timeoutError();
    } on ApiError {
      rethrow;
    } catch (e) {
      throw ApiError.unknownError('Login error: $e');
    }
  }

  // Get user data
  Future<User> getUserData() async {
    try {
      final accessToken = await getAccessToken();

      if (accessToken == null) {
        throw ApiError(
          errorCode: 'AUTH_INVALID_TOKEN',
          message: 'No access token found',
        );
      }

      print(
        '🔑 [AuthService] Getting user data with token: ${accessToken.substring(0, 20)}...',
      );

      final response = await http
          .get(
            Uri.parse('$baseUrl/user'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 30));

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ [AuthService] User data received');
        print('   Response body: $responseBody');
        final userResponse = UserResponse.fromJson(responseBody);
        print('   User name: ${userResponse.data.name}');
        print('   User email: ${userResponse.data.email}');
        return userResponse.data;
      } else if (response.statusCode == 401) {
        // Token expired, clear tokens
        await clearTokens();
        if (ApiError.isErrorResponse(responseBody)) {
          throw ApiError.fromJson(
            responseBody,
            statusCode: response.statusCode,
          );
        } else {
          throw ApiError(
            errorCode: 'AUTH_SESSION_EXPIRED',
            message: 'Session expired',
            statusCode: 401,
          );
        }
      } else {
        if (ApiError.isErrorResponse(responseBody)) {
          throw ApiError.fromJson(
            responseBody,
            statusCode: response.statusCode,
          );
        } else {
          throw ApiError.unknownError(
            'Failed to get user data: ${response.statusCode}',
          );
        }
      }
    } on SocketException {
      throw ApiError.networkError();
    } on TimeoutException {
      throw ApiError.timeoutError();
    } on ApiError {
      rethrow;
    } catch (e) {
      throw ApiError.unknownError('Get user error: $e');
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
      final response = await http
          .post(
            Uri.parse('$baseUrl/magic-link'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return MagicLinkResponse.fromJson(responseBody);
      } else {
        if (ApiError.isErrorResponse(responseBody)) {
          throw ApiError.fromJson(
            responseBody,
            statusCode: response.statusCode,
          );
        } else {
          throw ApiError.unknownError(
            'Failed to send magic link: ${response.statusCode}',
          );
        }
      }
    } on SocketException {
      throw ApiError.networkError();
    } on TimeoutException {
      throw ApiError.timeoutError();
    } on ApiError {
      rethrow;
    } catch (e) {
      throw ApiError.unknownError('Send magic link error: $e');
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

  // Register new user with password
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RegisterResponse.fromJson(responseBody);
      } else {
        // Parsear error del backend
        if (ApiError.isErrorResponse(responseBody)) {
          throw ApiError.fromJson(
            responseBody,
            statusCode: response.statusCode,
          );
        } else {
          throw ApiError.unknownError(
            'Registration failed: ${response.statusCode}',
          );
        }
      }
    } on SocketException {
      throw ApiError.networkError();
    } on TimeoutException {
      throw ApiError.timeoutError();
    } on ApiError {
      rethrow;
    } catch (e) {
      throw ApiError.unknownError('Register error: $e');
    }
  }

  // Save tokens from email verification deep link
  Future<void> saveVerificationTokens(
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
