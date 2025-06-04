// lib/core/usecases/usecase.dart
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}

abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}