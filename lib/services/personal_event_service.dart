import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/personal_event_models.dart';
import '../models/api_error.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class PersonalEventService {
  final AuthService _authService = AuthService();

  Future<PersonalEventResponse> createPersonalEvent(
    CreatePersonalEventRequest request,
  ) async {
    try {
      final accessToken = await _authService.getAccessToken();

      if (accessToken == null) {
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'No access token found',
        );
      }

      print('🔵 [PersonalEventService] Creating event: ${request.toJson()}');

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/calendar/events'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      print(
        '🔵 [PersonalEventService] Response status: ${response.statusCode}',
      );
      print('🔵 [PersonalEventService] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final eventResponse = PersonalEventResponse.fromJson(
          jsonDecode(response.body),
        );
        print('✅ [PersonalEventService] Event created successfully');
        return eventResponse;
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
          final error = ApiError.fromJson(
            body,
            statusCode: response.statusCode,
          );
          print('❌ [PersonalEventService] API Error: ${error.message}');
          throw error;
        }
        throw ApiError(
          errorCode: 'PERSONAL_EVENT_CREATE_FAILED',
          message: 'Failed to create personal event',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      print('❌ [PersonalEventService] Network error');
      throw ApiError.networkError();
    } on TimeoutException {
      print('❌ [PersonalEventService] Request timeout');
      throw ApiError.timeoutError();
    } on ApiError {
      rethrow;
    } catch (e) {
      print('❌ [PersonalEventService] Unexpected error: $e');
      throw ApiError(
        errorCode: 'PERSONAL_EVENT_CREATE_FAILED',
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}
