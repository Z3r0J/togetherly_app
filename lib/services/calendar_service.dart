import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/unified_calendar_models.dart';
import '../models/api_error.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class CalendarService {
  final AuthService _authService = AuthService();

  Future<CalendarData> getUnifiedCalendar({
    DateTime? startDate,
    DateTime? endDate,
    String filter = 'all',
  }) async {
    try {
      final accessToken = await _authService.getAccessToken();

      if (accessToken == null) {
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'No access token found',
        );
      }

      // Build query parameters
      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toUtc().toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toUtc().toIso8601String();
      }
      if (filter != 'all') {
        queryParams['filter'] = filter;
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/calendar/unified',
      ).replace(queryParameters: queryParams);

      print('🔵 [CalendarService] Fetching unified calendar...');
      print('🔵 [CalendarService] URL: $uri');

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('🔵 [CalendarService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ [CalendarService] Calendar fetched successfully');
        final data = jsonData['data'] as Map<String, dynamic>;
        return CalendarData.fromJson(data);
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
          print('❌ [CalendarService] API Error: ${error.message}');
          throw error;
        }
        throw ApiError(
          errorCode: 'CALENDAR_LOAD_FAILED',
          message: 'Failed to load calendar',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      print('❌ [CalendarService] Network error');
      throw ApiError.networkError();
    } on TimeoutException {
      print('❌ [CalendarService] Request timeout');
      throw ApiError.timeoutError();
    } on ApiError {
      rethrow;
    } catch (e) {
      print('❌ [CalendarService] Unexpected error: $e');
      throw ApiError(
        errorCode: 'CALENDAR_LOAD_FAILED',
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}
