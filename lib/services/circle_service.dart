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

  // Create a new circle
  Future<CreateCircleResponse> createCircle(CreateCircleRequest request) async {
    try {
      print('🔵 [CircleService] createCircle started');
      final accessToken = await _authService.getAccessToken();

      print(
        '🔑 [CircleService] Access Token: ${accessToken != null ? "${accessToken.substring(0, 20)}..." : "NULL"}',
      );

      if (accessToken == null) {
        print('❌ [CircleService] No access token found!');
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'No access token found',
        );
      }

      print('📤 [CircleService] Creating circle: ${request.name}');
      print('   API URL: ${ApiConfig.circlesUrl}');
      print('   Request body: ${jsonEncode(request.toJson())}');

      final response = await http
          .post(
            Uri.parse(ApiConfig.circlesUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      print('📥 [CircleService] Response status: ${response.statusCode}');
      print('📥 [CircleService] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [CircleService] Success response (${response.statusCode})');
        final createCircleResponse = CreateCircleResponse.fromJson(
          jsonDecode(response.body),
        );
        print('   Parsed response - success: ${createCircleResponse.success}');
        return createCircleResponse;
      } else if (response.statusCode == 401) {
        print('❌ [CircleService] Unauthorized (401) - clearing tokens');
        await _authService.clearTokens();
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'Session expired',
          statusCode: 401,
        );
      } else {
        print('❌ [CircleService] Error response (${response.statusCode})');
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (ApiError.isErrorResponse(body)) {
          print('   API Error detected: ${body}');
          throw ApiError.fromJson(body, statusCode: response.statusCode);
        }
        print('   Generic error thrown');
        throw ApiError(
          errorCode: 'CIRCLE_CREATE_FAILED',
          message: 'Failed to create circle',
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

  // Get circle details by ID
  Future<CircleDetailResponse> getCircleDetail(String circleId) async {
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
            Uri.parse('${ApiConfig.circlesUrl}/$circleId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final circleDetailResponse = CircleDetailResponse.fromJson(
          jsonDecode(response.body),
        );
        return circleDetailResponse;
      } else if (response.statusCode == 401) {
        await _authService.clearTokens();
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'Session expired',
          statusCode: 401,
        );
      } else if (response.statusCode == 404) {
        throw ApiError(
          errorCode: 'CIRCLE_NOT_FOUND',
          message: 'Circle not found',
          statusCode: 404,
        );
      } else {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (ApiError.isErrorResponse(body)) {
          throw ApiError.fromJson(body, statusCode: response.statusCode);
        }
        throw ApiError(
          errorCode: 'CIRCLE_LOAD_FAILED',
          message: 'Failed to load circle details',
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

  // Update a circle
  Future<UpdateCircleResponse> updateCircle(
    String circleId,
    UpdateCircleRequest request,
  ) async {
    try {
      print('🔵 [CircleService] updateCircle started');
      final accessToken = await _authService.getAccessToken();

      if (accessToken == null) {
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'No access token found',
        );
      }

      final updateUrl = '${ApiConfig.circlesUrl}/$circleId';
      print('📤 [CircleService] Updating circle: $circleId');
      print('   API URL: $updateUrl');
      print('   Request body: ${jsonEncode(request.toJson())}');

      final response = await http
          .put(
            Uri.parse(updateUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      print('📥 [CircleService] Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final updateResponse = UpdateCircleResponse.fromJson(
          jsonDecode(response.body),
        );
        print('✅ [CircleService] Circle updated successfully');
        return updateResponse;
      } else if (response.statusCode == 401) {
        await _authService.clearTokens();
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'Session expired',
          statusCode: 401,
        );
      } else if (response.statusCode == 404) {
        throw ApiError(
          errorCode: 'CIRCLE_NOT_FOUND',
          message: 'Circle not found',
          statusCode: 404,
        );
      } else {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (ApiError.isErrorResponse(body)) {
          throw ApiError.fromJson(body, statusCode: response.statusCode);
        }
        throw ApiError(
          errorCode: 'CIRCLE_UPDATE_FAILED',
          message: 'Failed to update circle',
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

  // Delete a circle
  Future<DeleteCircleResponse> deleteCircle(String circleId) async {
    try {
      print('🔵 [CircleService] deleteCircle started');
      final accessToken = await _authService.getAccessToken();

      if (accessToken == null) {
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'No access token found',
        );
      }

      final deleteUrl = '${ApiConfig.circlesUrl}/$circleId';
      print('📤 [CircleService] Deleting circle: $circleId');
      print('   API URL: $deleteUrl');

      final response = await http
          .delete(
            Uri.parse(deleteUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('📥 [CircleService] Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final deleteResponse = DeleteCircleResponse.fromJson(
          jsonDecode(response.body),
        );
        print('✅ [CircleService] Circle deleted successfully');
        return deleteResponse;
      } else if (response.statusCode == 401) {
        await _authService.clearTokens();
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'Session expired',
          statusCode: 401,
        );
      } else if (response.statusCode == 404) {
        throw ApiError(
          errorCode: 'CIRCLE_NOT_FOUND',
          message: 'Circle not found',
          statusCode: 404,
        );
      } else {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (ApiError.isErrorResponse(body)) {
          throw ApiError.fromJson(body, statusCode: response.statusCode);
        }
        throw ApiError(
          errorCode: 'CIRCLE_DELETE_FAILED',
          message: 'Failed to delete circle',
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

  // Send circle invitation
  Future<SendInvitationResponse> sendInvitation(
    String circleId,
    SendInvitationRequest request,
  ) async {
    try {
      print('🔵 [CircleService] sendInvitation started');
      final accessToken = await _authService.getAccessToken();

      if (accessToken == null) {
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'No access token found',
        );
      }

      final inviteUrl = '${ApiConfig.circlesUrl}/$circleId/invite';
      print('📤 [CircleService] Sending invitation to circle: $circleId');
      print('   API URL: $inviteUrl');
      print('   Emails: ${request.emails.join(", ")}');

      final response = await http
          .post(
            Uri.parse(inviteUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      print('📥 [CircleService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final invitationResponse = SendInvitationResponse.fromJson(
          jsonDecode(response.body),
        );
        print('✅ [CircleService] Invitations sent successfully');
        print('   Success: ${invitationResponse.data.success.length}');
        print('   Failed: ${invitationResponse.data.failed.length}');
        return invitationResponse;
      } else if (response.statusCode == 401) {
        await _authService.clearTokens();
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'Session expired',
          statusCode: 401,
        );
      } else if (response.statusCode == 403) {
        throw ApiError(
          errorCode: 'FORBIDDEN',
          message: 'Only circle owner or admin can send invitations',
          statusCode: 403,
        );
      } else if (response.statusCode == 404) {
        throw ApiError(
          errorCode: 'CIRCLE_NOT_FOUND',
          message: 'Circle not found',
          statusCode: 404,
        );
      } else {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (ApiError.isErrorResponse(body)) {
          throw ApiError.fromJson(body, statusCode: response.statusCode);
        }
        throw ApiError(
          errorCode: 'INVITATION_SEND_FAILED',
          message: 'Failed to send invitations',
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

  // Get invitation details (public endpoint)
  Future<InvitationDetailsResponse> getInvitationDetails(String token) async {
    try {
      print('🔵 [CircleService] getInvitationDetails started');
      final inviteUrl = '${ApiConfig.circlesUrl}/invitations/$token';
      print('📤 [CircleService] Getting invitation details');
      print('   API URL: $inviteUrl');

      final response = await http
          .get(
            Uri.parse(inviteUrl),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      print('📥 [CircleService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final detailsResponse = InvitationDetailsResponse.fromJson(
          jsonDecode(response.body),
        );
        print('✅ [CircleService] Invitation details retrieved');
        print('   Circle: ${detailsResponse.data.circleName}');
        print('   Inviter: ${detailsResponse.data.inviterName}');
        print('   Email: ${detailsResponse.data.invitedEmail}');
        print('   Is Registered: ${detailsResponse.data.isRegistered}');
        return detailsResponse;
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        throw ApiError.fromJson(body, statusCode: response.statusCode);
      } else if (response.statusCode == 410) {
        throw ApiError(
          errorCode: 'INVITATION_EXPIRED',
          message: 'This invitation has expired',
          statusCode: 410,
        );
      } else {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (ApiError.isErrorResponse(body)) {
          throw ApiError.fromJson(body, statusCode: response.statusCode);
        }
        throw ApiError(
          errorCode: 'INVITATION_LOAD_FAILED',
          message: 'Failed to load invitation details',
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

  // Accept invitation
  Future<AcceptInvitationResponse> acceptInvitation(String token) async {
    try {
      print('🔵 [CircleService] acceptInvitation started');
      final accessToken = await _authService.getAccessToken();

      if (accessToken == null) {
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'No access token found',
        );
      }

      print('   Access token: ${accessToken.substring(0, 20)}...');

      final acceptUrl = '${ApiConfig.circlesUrl}/invitations/$token/accept';
      print('📤 [CircleService] Accepting invitation');
      print('   API URL: $acceptUrl');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
      print('   Headers: ${headers.keys.toList()}');

      final response = await http
          .post(Uri.parse(acceptUrl), headers: headers)
          .timeout(const Duration(seconds: 10));

      print('📥 [CircleService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final acceptResponse = AcceptInvitationResponse.fromJson(
          jsonDecode(response.body),
        );
        print('✅ [CircleService] Invitation accepted successfully');
        return acceptResponse;
      } else if (response.statusCode == 401) {
        // Don't clear tokens here - let the app handle auth globally
        // The 401 might be from the invitation endpoint, not expired session
        final Map<String, dynamic> body = jsonDecode(response.body);
        print('❌ [CircleService] 401 Response body: $body');
        throw ApiError.fromJson(body, statusCode: response.statusCode);
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        throw ApiError.fromJson(body, statusCode: response.statusCode);
      } else if (response.statusCode == 410) {
        throw ApiError(
          errorCode: 'INVITATION_EXPIRED',
          message: 'This invitation has expired',
          statusCode: 410,
        );
      } else {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (ApiError.isErrorResponse(body)) {
          throw ApiError.fromJson(body, statusCode: response.statusCode);
        }
        throw ApiError(
          errorCode: 'INVITATION_ACCEPT_FAILED',
          message: 'Failed to accept invitation',
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

  // Get circle details by share token (public, no auth required)
  Future<CircleSharePreview> getCircleByShareToken(String shareToken) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.circlesUrl}/share/$shareToken'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return CircleSharePreview.fromJson(body['data']);
      } else {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (ApiError.isErrorResponse(body)) {
          throw ApiError.fromJson(body, statusCode: response.statusCode);
        }
        throw ApiError(
          errorCode: 'CIRCLE_LOAD_FAILED',
          message: 'Failed to load circle details',
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

  // Generate share link for a circle
  Future<GenerateShareLinkResult> generateShareLink(String circleId) async {
    try {
      final accessToken = await _authService.getAccessToken();

      if (accessToken == null) {
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'No access token found',
        );
      }

      final response = await http
          .post(
            Uri.parse('${ApiConfig.circlesUrl}/$circleId/share-link'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return GenerateShareLinkResult.fromJson(body['data']);
      } else if (response.statusCode == 401) {
        await _authService.clearTokens();
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'Session expired',
          statusCode: 401,
        );
      } else if (response.statusCode == 403) {
        throw ApiError(
          errorCode: 'CIRCLE_MEMBER_PERMISSION_DENIED',
          message: 'Only circle owner or admin can generate share link',
          statusCode: 403,
        );
      } else {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (ApiError.isErrorResponse(body)) {
          throw ApiError.fromJson(body, statusCode: response.statusCode);
        }
        throw ApiError(
          errorCode: 'GENERATE_SHARE_LINK_FAILED',
          message: 'Failed to generate share link',
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

  // Join a circle via share token (requires auth)
  Future<JoinCircleResult> joinCircleViaShareLink(String shareToken) async {
    try {
      final accessToken = await _authService.getAccessToken();

      if (accessToken == null) {
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'No access token found',
        );
      }

      final response = await http
          .post(
            Uri.parse('${ApiConfig.circlesUrl}/share/$shareToken/join'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return JoinCircleResult.fromJson(body['data']);
      } else if (response.statusCode == 401) {
        await _authService.clearTokens();
        throw ApiError(
          errorCode: 'AUTH_SESSION_EXPIRED',
          message: 'Session expired',
          statusCode: 401,
        );
      } else if (response.statusCode == 409) {
        throw ApiError(
          errorCode: 'ALREADY_CIRCLE_MEMBER',
          message: 'You are already a member of this circle',
          statusCode: 409,
        );
      } else {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (ApiError.isErrorResponse(body)) {
          throw ApiError.fromJson(body, statusCode: response.statusCode);
        }
        throw ApiError(
          errorCode: 'CIRCLE_JOIN_FAILED',
          message: 'Failed to join circle',
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
