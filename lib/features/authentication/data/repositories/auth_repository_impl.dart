import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_local_datasource.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.login(
          email: email,
          password: password,
        );

        // Cache user data locally
        await localDataSource.cacheUser(userModel);
        
        // Cache token if available
        if (userModel.token != null) {
          await localDataSource.cacheToken(userModel.token!);
        }

        return Right(userModel.toEntity());
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on TimeoutException catch (e) {
        return Left(TimeoutFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } catch (e) {
        return Left(UnknownFailure(
          message: 'Error inesperado: $e',
        ));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No hay conexión a internet',
      ));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String career,
    required int semester,
    required String campus,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.register(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          dateOfBirth: dateOfBirth,
          career: career,
          semester: semester,
          campus: campus,
        );

        // FIXED: Don't cache user data or token after registration
        // The user should login manually for security reasons
        
        // Just return the user entity without caching anything
        // This allows the UI to show success but doesn't authenticate the user
        return Right(userModel.toEntity());
        
      } on ConflictException catch (e) {
        return Left(UserAlreadyExistsFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on TimeoutException catch (e) {
        return Left(TimeoutFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } catch (e) {
        return Left(UnknownFailure(
          message: 'Error inesperado: $e',
        ));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No hay conexión a internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Try to logout from server if connected
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.logout();
        } catch (e) {
          // Continue with local logout even if server logout fails
        }
      }

      // Clear local data
      await localDataSource.clearAllAuthData();

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Error al cerrar sesión: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // First try to get cached user
      final cachedUser = await localDataSource.getCachedUser();
      
      if (cachedUser != null) {
        // If connected, try to sync with server
        if (await networkInfo.isConnected) {
          try {
            final serverUser = await remoteDataSource.getCurrentUser();
            // Update cache with latest data
            await localDataSource.cacheUser(serverUser);
            return Right(serverUser.toEntity());
          } catch (e) {
            // Return cached user if server fails
            return Right(cachedUser.toEntity());
          }
        } else {
          return Right(cachedUser.toEntity());
        }
      } else {
        // No cached user, must fetch from server
        if (await networkInfo.isConnected) {
          try {
            final serverUser = await remoteDataSource.getCurrentUser();
            await localDataSource.cacheUser(serverUser);
            return Right(serverUser.toEntity());
          } on UnauthorizedException catch (e) {
            return Left(UnauthorizedFailure(
              message: e.message,
              code: e.statusCode,
            ));
          } on NotFoundException catch (e) {
            return Left(UserNotFoundFailure(
              message: e.message,
              code: e.statusCode,
            ));
          } on ServerException catch (e) {
            return Left(ServerFailure(
              message: e.message,
              code: e.statusCode,
            ));
          }
        } else {
          return const Left(NetworkFailure(
            message: 'No hay conexión a internet y no hay datos en caché',
          ));
        }
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Error inesperado: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await localDataSource.isLoggedIn();
      return Right(isLoggedIn);
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Error al verificar estado de login: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmail(String token) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.verifyEmail(token);
        return const Right(null);
      } on ValidationException catch (e) {
        return Left(ValidationFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on UnauthorizedException catch (e) {
        return Left(UnauthorizedFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } catch (e) {
        return Left(UnknownFailure(
          message: 'Error inesperado: $e',
        ));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No hay conexión a internet',
      ));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? bio,
    List<String>? interests,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.updateProfile(
          bio: bio,
          interests: interests,
        );

        // Update cache with new data
        await localDataSource.cacheUser(userModel);

        return Right(userModel.toEntity());
      } on ValidationException catch (e) {
        return Left(ValidationFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on UnauthorizedException catch (e) {
        return Left(UnauthorizedFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } catch (e) {
        return Left(UnknownFailure(
          message: 'Error inesperado: $e',
        ));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No hay conexión a internet',
      ));
    }
  }

  // Rest of the methods remain the same...
  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // TODO: Implement when available in API
        return const Right(null);
      } on ValidationException catch (e) {
        return Left(ValidationFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on AuthenticationException catch (e) {
        return Left(AuthenticationFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on UnauthorizedException catch (e) {
        return Left(UnauthorizedFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } catch (e) {
        return Left(UnknownFailure(
          message: 'Error inesperado: $e',
        ));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No hay conexión a internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    if (await networkInfo.isConnected) {
      try {
        // TODO: Implement when available in API
        await localDataSource.clearAllAuthData();
        return const Right(null);
      } on UnauthorizedException catch (e) {
        return Left(UnauthorizedFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } catch (e) {
        return Left(UnknownFailure(
          message: 'Error inesperado: $e',
        ));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No hay conexión a internet',
      ));
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken() async {
    if (await networkInfo.isConnected) {
      try {
        // TODO: Implement when available in API
        return const Left(ServerFailure(message: 'Refresh token no implementado'));
      } on UnauthorizedException catch (e) {
        // Clear local data if refresh fails
        await localDataSource.clearAllAuthData();
        return Left(UnauthorizedFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } catch (e) {
        return Left(UnknownFailure(
          message: 'Error inesperado: $e',
        ));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No hay conexión a internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllAuthData() async {
    try {
      await localDataSource.clearAllAuthData();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(
        message: e.message,
        code: e.statusCode,
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Error al limpiar datos de autenticación: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({
    required String email,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // TODO: Implement when available in API
        return const Right(null);
      } on ValidationException catch (e) {
        return Left(ValidationFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on NotFoundException catch (e) {
        return Left(UserNotFoundFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } catch (e) {
        return Left(UnknownFailure(
          message: 'Error inesperado: $e',
        ));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No hay conexión a internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // TODO: Implement when available in API
        return const Right(null);
      } on ValidationException catch (e) {
        return Left(ValidationFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on UnauthorizedException catch (e) {
        return Left(UnauthorizedFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } catch (e) {
        return Left(UnknownFailure(
          message: 'Error inesperado: $e',
        ));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No hay conexión a internet',
      ));
    }
  }
}