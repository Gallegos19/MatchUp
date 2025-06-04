import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

// User-related failures
class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

class UserAlreadyExistsFailure extends Failure {
  const UserAlreadyExistsFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}

// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    required String message,
    int? code,
  }) : super(message: message, code: code);
}