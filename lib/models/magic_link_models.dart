// Magic Link Request Model
class MagicLinkRequest {
  final String email;

  MagicLinkRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

// Magic Link Response Model
class MagicLinkResponse {
  final bool success;

  MagicLinkResponse({required this.success});

  factory MagicLinkResponse.fromJson(Map<String, dynamic> json) {
    return MagicLinkResponse(success: json['success'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {'success': success};
  }
}

// Deep Link Auth Data Model
// Extracted from URL parameters: togetherly://auth/success?accessToken=xxx&refreshToken=yyy
class DeepLinkAuthData {
  final String accessToken;
  final String refreshToken;

  DeepLinkAuthData({required this.accessToken, required this.refreshToken});

  factory DeepLinkAuthData.fromUri(Uri uri) {
    final accessToken = uri.queryParameters['accessToken'] ?? '';
    final refreshToken = uri.queryParameters['refreshToken'] ?? '';

    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw Exception('Missing authentication tokens in deep link');
    }

    return DeepLinkAuthData(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  bool get isValid => accessToken.isNotEmpty && refreshToken.isNotEmpty;
}
