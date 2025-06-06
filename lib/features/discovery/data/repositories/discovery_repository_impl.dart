// lib/features/discovery/data/repositories/discovery_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:matchup/features/discovery/domain/entities/discovery_filters.dart';
import 'package:matchup/features/discovery/domain/entities/swipe_action.dart';
import 'package:matchup/features/discovery/domain/repositories/discovery_repository.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/profile.dart';
import '../datasource/discovery_remote_datasource.dart';

class DiscoveryRepositoryImpl implements DiscoveryRepository {
  final DiscoveryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  // Store filters in memory for demonstration; replace with persistent storage if needed
  DiscoveryFilters? _currentFilters;

  DiscoveryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, DiscoveryFilters>> getFilters() async {
    // You can replace this with persistent storage logic if needed
    if (_currentFilters != null) {
      return Right(_currentFilters!);
    } else {
      return Left(UnknownFailure(message: 'No filters set'));
    }
  }

  @override
  Future<Either<Failure, void>> updateFilters({required DiscoveryFilters filters}) async {
    _currentFilters = filters;
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Profile>>> getProfiles({
    DiscoveryFilters? filters,
    int page = 1,
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final profileModels = await remoteDataSource.getProfiles(
          filters: filters,
          page: page,
          limit: limit,
        );

        final profiles = profileModels.map((model) => model.toEntity()).toList();
        return Right(profiles);
      } catch (e) {
        return _handleException(e);
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No hay conexión a internet',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> swipeProfile({
    required String profileId,
    required SwipeAction action,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final isMatch = await remoteDataSource.swipeProfile(
          profileId: profileId,
          action: action,
        );

        return Right(isMatch);
      } catch (e) {
        return _handleException(e);
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No hay conexión a internet',
      ));
    }
  }

  @override
  Future<Either<Failure, Profile>> getProfileDetails({
    required String profileId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final profileModel = await remoteDataSource.getProfileDetails(
          profileId: profileId,
        );

        return Right(profileModel.toEntity());
      } catch (e) {
        return _handleException(e);
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No hay conexión a internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> reportProfile({
    required String profileId,
    required String reason,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.reportProfile(
          profileId: profileId,
          reason: reason,
        );

        return const Right(null);
      } catch (e) {
        return _handleException(e);
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No hay conexión a internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> blockProfile({
    required String profileId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.blockProfile(profileId: profileId);
        return const Right(null);
      } catch (e) {
        return _handleException(e);
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No hay conexión a internet',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Profile>>> getLikedProfiles({
    int page = 1,
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final profileModels = await remoteDataSource.getLikedProfiles(
          page: page,
          limit: limit,
        );

        final profiles = profileModels.map((model) => model.toEntity()).toList();
        return Right(profiles);
      } catch (e) {
        return _handleException(e);
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No hay conexión a internet',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Profile>>> getPassedProfiles({
    int page = 1,
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final profileModels = await remoteDataSource.getPassedProfiles(
          page: page,
          limit: limit,
        );

        final profiles = profileModels.map((model) => model.toEntity()).toList();
        return Right(profiles);
      } catch (e) {
        return _handleException(e);
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No hay conexión a internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> undoLastSwipe() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.undoLastSwipe();
        return const Right(null);
      } catch (e) {
        return _handleException(e);
      }
    } else {
      return const Left(NetworkFailure(
        message: 'No hay conexión a internet',
      ));
    }
  }

  Either<Failure, T> _handleException<T>(Object e) {
    if (e is ValidationException) {
      return Left(ValidationFailure(message: e.message, code: e.statusCode));
    } else if (e is UnauthorizedException) {
      return Left(UnauthorizedFailure(message: e.message, code: e.statusCode));
    } else if (e is NotFoundException) {
      return Left(UserNotFoundFailure(message: e.message, code: e.statusCode));
    } else if (e is NetworkException) {
      return Left(NetworkFailure(message: e.message, code: e.statusCode));
    } else if (e is TimeoutException) {
      return Left(TimeoutFailure(message: e.message, code: e.statusCode));
    } else if (e is ServerException) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } else {
      return Left(UnknownFailure(message: 'Error inesperado: $e'));
    }
  }
}