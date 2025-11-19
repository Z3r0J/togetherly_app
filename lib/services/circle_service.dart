import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/circle_models.dart';
import '../models/api_error.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class CircleService {
  final AuthService _authService = AuthService();

  // Get all circles for the current user
  Future<CirclesResponse> getCircles() async {
    try {
      final accessToken = await _authService.getAccessToken();

      if (accessToken == null) {
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'No access token found',
        );
      }

      final response = await http
          .get(
            Uri.parse(ApiConfig.circlesUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final circlesResponse = CirclesResponse.fromJson(
          jsonDecode(response.body),
        );
        return circlesResponse;
      } else if (response.statusCode == 401) {
        await _authService.clearTokens();
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'Session expired',
          statusCode: 401,
        );
      } else {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (ApiError.isErrorResponse(body)) {
          throw ApiError.fromJson(body, statusCode: response.statusCode);
        }
        throw ApiError(
          errorCode: 'CIRCLE_LOAD_FAILED',
          message: 'Failed to load circles',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw ApiError.networkError();
    } on TimeoutException {
      throw ApiError.timeoutError();
    } on ApiError {
      rethrow;
    } catch (e) {
      throw ApiError.unknownError(e.toString());
    }
  }
}
