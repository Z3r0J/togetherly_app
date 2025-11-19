class RegisterRequest {
  final String name;
  final String email;
  final String password;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'password': password};
  }
}

class RegisterResponse {
  final bool success;
  final String userId;

  RegisterResponse({required this.success, required this.userId});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? false,
      userId: json['data']['userId'] ?? '',
    );
  }
}

class EmailVerificationData {
  final String accessToken;
  final String refreshToken;

  EmailVerificationData({
    required this.accessToken,
    required this.refreshToken,
  });

  factory EmailVerificationData.fromUri(Uri uri) {
    final accessToken = uri.queryParameters['accessToken'] ?? '';
    final refreshToken = uri.queryParameters['refreshToken'] ?? '';

    return EmailVerificationData(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
