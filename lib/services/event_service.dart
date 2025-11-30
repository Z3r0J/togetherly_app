import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_error.dart';
import '../models/circle_event_models.dart';
import '../models/personal_event_models.dart';
import 'auth_service.dart';
import '../widgets/rsvp_widgets.dart';

class EventService {
  final AuthService _authService = AuthService();

  Future<CircleEventDetail> getCircleEventDetail(String eventId) async {
    final accessToken = await _requireToken();

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/events/$eventId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
        final data = jsonBody['data'] ?? jsonBody['event'] ?? jsonBody;
        return CircleEventDetail.fromJson(data as Map<String, dynamic>);
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
          errorCode: 'CIRCLE_EVENT_LOAD_FAILED',
          message: 'Failed to load event detail',
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

  Future<void> updateRsvp(String eventId, RsvpStatus status) async {
    final accessToken = await _requireToken();

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/events/$eventId/rsvp'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({'status': _rsvpToApi(status)}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) return;

      if (response.statusCode == 401) {
        await _authService.clearTokens();
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'Session expired',
          statusCode: 401,
        );
      }

      final Map<String, dynamic> body = jsonDecode(response.body);
      if (ApiError.isErrorResponse(body)) {
        throw ApiError.fromJson(body, statusCode: response.statusCode);
      }
      throw ApiError(
        errorCode: 'RSVP_UPDATE_FAILED',
        message: 'Failed to update RSVP',
        statusCode: response.statusCode,
      );
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

  Future<void> voteEventTime(String eventId, String eventTimeId) async {
    final accessToken = await _requireToken();

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/events/$eventId/vote'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({'eventTimeId': eventTimeId}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) return;

      if (response.statusCode == 401) {
        await _authService.clearTokens();
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'Session expired',
          statusCode: 401,
        );
      }

      final Map<String, dynamic> body = jsonDecode(response.body);
      if (ApiError.isErrorResponse(body)) {
        throw ApiError.fromJson(body, statusCode: response.statusCode);
      }
      throw ApiError(
        errorCode: 'EVENT_VOTE_FAILED',
        message: 'Failed to vote for time',
        statusCode: response.statusCode,
      );
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

  String _rsvpToApi(RsvpStatus status) {
    switch (status) {
      case RsvpStatus.going:
        return 'going';
      case RsvpStatus.maybe:
        return 'maybe';
      case RsvpStatus.notGoing:
        return 'not going';
      case RsvpStatus.none:
        return 'not going';
    }
  }

  Future<PersonalEvent> getPersonalEventDetail(String eventId) async {
    final accessToken = await _requireToken();

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/calendar/events/$eventId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
        final data = jsonBody['data'] ?? jsonBody;
        return PersonalEvent.fromJson(data as Map<String, dynamic>);
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
          errorCode: 'PERSONAL_EVENT_LOAD_FAILED',
          message: 'Failed to load personal event detail',
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

  Future<String> _requireToken() async {
    final token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw ApiError(
        errorCode: 'AUTH_SESSION_EXPIRED',
        message: 'No access token found',
        statusCode: 401,
      );
    }
    return token;
  }

  Future<void> createCircleEvent(Map<String, dynamic> payload) async {
    final accessToken = await _requireToken();

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/events'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      if (response.statusCode == 401) {
        await _authService.clearTokens();
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'Session expired',
          statusCode: 401,
        );
      }

      final Map<String, dynamic> body = jsonDecode(response.body);
      if (ApiError.isErrorResponse(body)) {
        throw ApiError.fromJson(body, statusCode: response.statusCode);
      }
      throw ApiError(
        errorCode: 'CIRCLE_EVENT_CREATE_FAILED',
        message: 'Failed to create circle event',
        statusCode: response.statusCode,
      );
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
