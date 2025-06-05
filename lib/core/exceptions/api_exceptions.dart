/// Base class for all API exceptions
abstract class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException(super.message);
}

class TimeoutException extends ApiException {
  const TimeoutException(super.message);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message);
}

class BadRequestException extends ApiException {
  const BadRequestException(super.message);
}

class ForbiddenException extends ApiException {
  const ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  const NotFoundException(super.message);
}

class ServerException extends ApiException {
  const ServerException(super.message);
}

class UnknownException extends ApiException {
  const UnknownException(super.message);
}

class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  ValidationException(String message, {this.errors}) : super(message);
}
