import 'package:shared_preferences/shared_preferences.dart';
import '../models/circle_models.dart';
import 'circle_service.dart';
import 'auth_service.dart';

class InvitationService {
  static const String _pendingInvitationTokenKey = 'pending_invitation_token';

  final CircleService _circleService;
  final AuthService _authService;

  InvitationService({CircleService? circleService, AuthService? authService})
    : _circleService = circleService ?? CircleService(),
      _authService = authService ?? AuthService();

  // Save invitation token when user is not logged in
  Future<void> savePendingInvitation(String token) async {
    print('💾 [InvitationService] Saving pending invitation token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingInvitationTokenKey, token);
  }

  // Get saved invitation token
  Future<String?> getPendingInvitation() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_pendingInvitationTokenKey);
    if (token != null) {
      print('📥 [InvitationService] Found pending invitation token');
    }
    return token;
  }

  // Clear invitation token after processing
  Future<void> clearPendingInvitation() async {
    print('🗑️ [InvitationService] Clearing pending invitation token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingInvitationTokenKey);
  }

  // Get invitation details (public endpoint - no auth needed)
  Future<InvitationDetails?> getInvitationDetails(String token) async {
    try {
      print('🔍 [InvitationService] Fetching invitation details');
      final response = await _circleService.getInvitationDetails(token);
      if (response.success) {
        print('✅ [InvitationService] Successfully fetched invitation details');
        print('   Circle: ${response.data.circleName}');
        print('   Invited email: ${response.data.invitedEmail}');
        return response.data;
      }
      return null;
    } catch (e) {
      print('❌ [InvitationService] Failed to fetch invitation details: $e');
      return null;
    }
  }

  // Accept invitation (requires auth)
  Future<AcceptInvitationData?> acceptInvitation(String token) async {
    try {
      print('🔵 [InvitationService] Accepting invitation');
      final response = await _circleService.acceptInvitation(token);
      if (response.success) {
        print('✅ [InvitationService] Successfully accepted invitation');
        print('   Circle: ${response.data.circleName}');
        return response.data;
      }
      return null;
    } catch (e) {
      print('❌ [InvitationService] Failed to accept invitation: $e');
      rethrow;
    }
  }

  // Process pending invitation after login/registration
  // Returns AcceptInvitationData if successful, null if no pending invitation
  Future<AcceptInvitationData?> processPendingInvitation() async {
    final token = await getPendingInvitation();
    if (token == null) {
      print('ℹ️ [InvitationService] No pending invitation to process');
      return null;
    }

    try {
      print('🔄 [InvitationService] Processing pending invitation');
      final result = await acceptInvitation(token);
      if (result != null) {
        await clearPendingInvitation();
        print(
          '✅ [InvitationService] Pending invitation processed successfully',
        );
        return result;
      }
      return null;
    } catch (e) {
      print('❌ [InvitationService] Error processing pending invitation: $e');
      // Keep token for retry
      rethrow;
    }
  }

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    final accessToken = await _authService.getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}
