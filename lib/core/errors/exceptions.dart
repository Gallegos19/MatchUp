class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'AppException: $message';
}

class ServerException extends AppException {
  ServerException({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException extends AppException {
  NetworkException({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException extends AppException {
  CacheException({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);

  @override
  String toString() => 'CacheException: $message';
}

class AuthenticationException extends AppException {
  AuthenticationException({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);

  @override
  String toString() => 'AuthenticationException: $message';
}

class UnauthorizedException extends AppException {
  UnauthorizedException({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class ValidationException extends AppException {
  ValidationException({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);

  @override
  String toString() => 'ValidationException: $message';
}

class NotFoundException extends AppException {
  NotFoundException({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);

  @override
  String toString() => 'NotFoundException: $message';
}

class ConflictException extends AppException {
  ConflictException({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);

  @override
  String toString() => 'ConflictException: $message';
}

class TimeoutException extends AppException {
  TimeoutException({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);

  @override
  String toString() => 'TimeoutException: $message';
}

class PermissionException extends AppException {
  PermissionException({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);

  @override
  String toString() => 'PermissionException: $message';
}