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
      } else {
        // Unknown deep link format
        onError?.call('Unknown deep link format: ${uri.toString()}');
      }
    } catch (e) {
      onError?.call('Failed to process deep link: $e');
    }
  }

  // Dispose subscription
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
