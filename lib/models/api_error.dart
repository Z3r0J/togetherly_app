/// Modelo de error estructurado que parsea respuestas de error del backend
///
/// El backend devuelve errores en este formato:
/// ```json
/// {
///   "success": false,
///   "errorCode": "AUTH_EMAIL_ALREADY_EXISTS",
///   "message": "This email is already registered",
///   "details": { ... },
///   "timestamp": "2025-11-19T10:30:00.000Z"
/// }
/// ```
class ApiError implements Exception {
  final String errorCode;
  final String message;
  final Map<String, dynamic>? details;
  final String? timestamp;
  final int? statusCode;

  ApiError({
    required this.errorCode,
    required this.message,
    this.details,
    this.timestamp,
    this.statusCode,
  });

  /// Crea un ApiError desde la respuesta JSON del backend
  factory ApiError.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    return ApiError(
      errorCode: json['errorCode'] ?? 'UNKNOWN_ERROR',
      message: json['message'] ?? 'An error occurred',
      details: json['details'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] as String?,
      statusCode: statusCode,
    );
  }

  /// Verifica si la respuesta es un error del backend
  static bool isErrorResponse(Map<String, dynamic> json) {
    return json['success'] == false && json.containsKey('errorCode');
  }

  @override
  String toString() {
    return 'ApiError(errorCode: $errorCode, message: $message, statusCode: $statusCode)';
  }

  /// Helper para crear errores de red comunes
  static ApiError networkError() {
    return ApiError(
      errorCode: 'NETWORK_ERROR',
      message: 'Network connection failed',
    );
  }

  static ApiError timeoutError() {
    return ApiError(errorCode: 'TIMEOUT_ERROR', message: 'Request timed out');
  }

  static ApiError unknownError([String? message]) {
    return ApiError(
      errorCode: 'UNKNOWN_ERROR',
      message: message ?? 'An unknown error occurred',
    );
  }
}
