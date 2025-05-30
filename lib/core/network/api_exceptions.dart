class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}

class NetworkException extends ApiException {
  NetworkException({super.message = 'Network error occurred'});
}

class AuthenticationException extends ApiException {
  AuthenticationException({super.message = 'Authentication failed'})
    : super(statusCode: 401);
}

class RateLimitException extends ApiException {
  final Duration retryAfter;

  RateLimitException({
    this.retryAfter = const Duration(minutes: 1),
    super.message = 'Rate limit exceeded',
  }) : super(statusCode: 429);
}

class ServerException extends ApiException {
  ServerException({super.message = 'Server error occurred'})
    : super(statusCode: 500);
}

class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  ValidationException({super.message = 'Validation failed', this.errors})
    : super(statusCode: 422, data: errors);
}
