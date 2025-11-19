class ApiConfig {
  // Base URL for all API endpoints
  static const String baseUrl = 'http://localhost:3000/api';

  // Endpoint paths
  static const String authPath = '/auth';
  static const String circlesPath = '/circles';

  // Full endpoint URLs
  static String get authUrl => '$baseUrl$authPath';
  static String get circlesUrl => '$baseUrl$circlesPath';
}
