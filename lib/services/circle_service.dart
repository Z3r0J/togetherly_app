import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/circle_models.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class CircleService {
  final AuthService _authService = AuthService();

  // Get all circles for the current user
  Future<CirclesResponse> getCircles() async {
    try {
      final accessToken = await _authService.getAccessToken();

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.circlesUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final circlesResponse = CirclesResponse.fromJson(
          jsonDecode(response.body),
        );
        return circlesResponse;
      } else if (response.statusCode == 401) {
        await _authService.clearTokens();
        throw Exception('Session expired');
      } else {
        throw Exception(
          'Failed to load circles: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Get circles error: $e');
    }
  }
}
