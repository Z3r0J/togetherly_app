class ApiConfig {
  // Base URL for all API endpoints
  static const String baseUrl = 'https://togetherly-backend.fly.dev/api';

  // Endpoint paths
  static const String authPath = '/auth';
  static const String circlesPath = '/circles';
  static const String notificationsPath = '/notifications';

  // Full endpoint URLs
  static String get authUrl => '$baseUrl$authPath';
  static String get circlesUrl => '$baseUrl$circlesPath';
  static String get notificationsUrl => '$baseUrl$notificationsPath';
}
