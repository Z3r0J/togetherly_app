import 'dart:async';
import 'package:app_links/app_links.dart';
import '../models/magic_link_models.dart';
import '../models/register_models.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _subscription;

  // Callback to handle deep link authentication
  Function(DeepLinkAuthData)? onAuthLinkReceived;
  Function(EmailVerificationData)? onEmailVerificationReceived;
  Function(String token)? onInvitationLinkReceived;
  Function(String shareToken)? onShareLinkReceived;
  Function(String error)? onError;

  // Initialize and listen for deep links
  Future<void> initialize() async {
    // Handle initial link if app was opened via deep link (app was closed)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      onError?.call('Failed to get initial link: $e');
    }

    // Listen for deep links while app is running or in background
    _subscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        onError?.call('Deep link error: $err');
      },
    );
  }

  // Handle deep link URIs
  void _handleDeepLink(Uri uri) {
    try {
      print('🔗 [DeepLinkService] Handling deep link: ${uri.toString()}');

      // Check if this is a magic link authentication
      // Expected format: togetherly://auth/success?accessToken=xxx&refreshToken=yyy
      if (uri.scheme == 'togetherly' &&
          uri.host == 'auth' &&
          uri.pathSegments.contains('success')) {
        // Parse authentication tokens from URL
        final authData = DeepLinkAuthData.fromUri(uri);

        if (authData.isValid) {
          onAuthLinkReceived?.call(authData);
        } else {
          onError?.call('Invalid authentication tokens in deep link');
        }
      }
      // Check if this is an email verification
      // Expected format: togetherly://auth/verified?accessToken=xxx&refreshToken=yyy
      else if (uri.scheme == 'togetherly' &&
          uri.host == 'auth' &&
          uri.pathSegments.contains('verified')) {
        // Parse authentication tokens from URL
        final verificationData = EmailVerificationData.fromUri(uri);

        if (verificationData.accessToken.isNotEmpty &&
            verificationData.refreshToken.isNotEmpty) {
          onEmailVerificationReceived?.call(verificationData);
        } else {
          onError?.call('Invalid verification tokens in deep link');
        }
      }
      // Check if this is a circle invitation
      // Expected format: togetherly://invite/{token}
      // OR: https://togetherly.app/invite/{token}
      else if ((uri.scheme == 'togetherly' && uri.host == 'invite') ||
          (uri.scheme == 'https' &&
              uri.host == 'togetherly.app' &&
              uri.pathSegments.isNotEmpty &&
              uri.pathSegments.first == 'invite')) {
        print('🔍 [DeepLinkService] Invitation link detected');
        print('   Scheme: ${uri.scheme}');
        print('   Host: ${uri.host}');
        print('   Path segments: ${uri.pathSegments}');

        // Extract token from path
        final token = uri.pathSegments.last;
        print(
          '   Extracted token: ${token.length > 10 ? token.substring(0, 10) + "..." : token}',
        );

        if (token.isNotEmpty && token != 'invite') {
          print(
            '📧 [DeepLinkService] Valid invitation token - calling callback',
          );
          onInvitationLinkReceived?.call(token);
        } else {
          print('❌ [DeepLinkService] Invalid invitation token');
          onError?.call('Invalid invitation token in deep link');
        }
      }
      // Check if this is a circle share link
      // Expected format: togetherly://circles/share/{shareToken}
      // OR: https://togetherly-backend.fly.dev/api/circles/share/{shareToken}/join
      else if ((uri.scheme == 'togetherly' &&
              uri.host == 'circles' &&
              uri.pathSegments.length >= 2 &&
              uri.pathSegments[0] == 'share') ||
          (uri.scheme == 'https' &&
              uri.host == 'togetherly-backend.fly.dev' &&
              uri.pathSegments.length >= 4 &&
              uri.pathSegments[0] == 'api' &&
              uri.pathSegments[1] == 'circles' &&
              uri.pathSegments[2] == 'share')) {
        print('🔍 [DeepLinkService] Share link detected');
        print('   Scheme: ${uri.scheme}');
        print('   Host: ${uri.host}');
        print('   Path segments: ${uri.pathSegments}');

        // Extract shareToken from path
        // For togetherly://circles/share/{shareToken} -> pathSegments[1]
        // For https://togetherly-backend.fly.dev/api/circles/share/{shareToken}/join -> pathSegments[3]
        final shareToken = uri.scheme == 'togetherly'
            ? uri.pathSegments[1]
            : uri.pathSegments[3];
        print(
          '   Extracted shareToken: ${shareToken.length > 10 ? shareToken.substring(0, 10) + "..." : shareToken}',
        );

        if (shareToken.isNotEmpty) {
          print('📧 [DeepLinkService] Valid share token - calling callback');
          onShareLinkReceived?.call(shareToken);
        } else {
          print('❌ [DeepLinkService] Invalid share token');
          onError?.call('Invalid share token in deep link');
        }
      } else {
        // Unknown deep link format
        print(
          '⚠️ [DeepLinkService] Unknown deep link format: ${uri.toString()}',
        );
        onError?.call('Unknown deep link format: ${uri.toString()}');
      }
    } catch (e) {
      print('❌ [DeepLinkService] Failed to process deep link: $e');
      onError?.call('Failed to process deep link: $e');
    }
  }

  // Dispose subscription
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
