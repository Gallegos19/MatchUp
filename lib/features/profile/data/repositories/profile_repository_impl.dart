import 'package:dartz/dartz.dart';
import 'package:matchup/features/profile/data/models/user_profile_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasource/profile_local_datasource.dart';
import '../datasource/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      // First try to get cached profile
      final cachedProfile = await localDataSource.getCachedProfile();
      
      if (await networkInfo.isConnected) {
        try {
          final remoteProfile = await remoteDataSource.getProfile();
          // Update cache with latest data
          await localDataSource.cacheProfile(remoteProfile);
          return Right(remoteProfile.toEntity());
        } catch (e) {
          // Return cached profile if server fails
          if (cachedProfile != null) {
            return Right(cachedProfile.toEntity());
          }
          return _handleException(e);
        }
      } else {
        if (cachedProfile != null) {
          return Right(cachedProfile.toEntity());
        } else {
          return const Left(NetworkFailure(
            message: 'No hay conexión a internet y no hay datos en caché',
          ));
        }
      }
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? career,
    String? semester,
    String? campus,
    List<String>? interests,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedProfile = await remoteDataSource.updateProfile(
          firstName: firstName,
          lastName: lastName,
          bio: bio,
          career: career,
          semester: semester,
          campus: campus,
          interests: interests,
        );

        // Update cache with new data
        await localDataSource.cacheProfile(updatedProfile);

        return Right(updatedProfile.toEntity());
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
  Future<Either<Failure, List<String>>> uploadPhotos(List<String> imagePaths) async {
    if (await networkInfo.isConnected) {
      try {
        final photoUrls = await remoteDataSource.uploadPhotos(imagePaths);
        
        // Update cached profile with new photos
        final cachedProfile = await localDataSource.getCachedProfile();
        if (cachedProfile != null) {
          final updatedProfile = cachedProfile.copyWith(
            photoUrls: [...cachedProfile.photoUrls, ...photoUrls],
          );
          await localDataSource.cacheProfile(updatedProfile as UserProfileModel);
        }

        return Right(photoUrls);
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
  Future<Either<Failure, void>> deletePhoto(String photoUrl) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deletePhoto(photoUrl);
        
        // Update cached profile
        final cachedProfile = await localDataSource.getCachedProfile();
        if (cachedProfile != null) {
          final updatedPhotoUrls = cachedProfile.photoUrls
              .where((url) => url != photoUrl)
              .toList();
          final updatedProfile = cachedProfile.copyWith(photoUrls: updatedPhotoUrls);
          await localDataSource.cacheProfile(updatedProfile as UserProfileModel);
        }

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
  Future<Either<Failure, void>> reorderPhotos(List<String> photoUrls) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.reorderPhotos(photoUrls);
        
        // Update cached profile
        final cachedProfile = await localDataSource.getCachedProfile();
        if (cachedProfile != null) {
          final updatedProfile = cachedProfile.copyWith(photoUrls: photoUrls);
          await localDataSource.cacheProfile(updatedProfile as UserProfileModel);
        }

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
  Future<Either<Failure, ProfileSettings>> getSettings() async {
    try {
      // First try to get cached settings
      final cachedSettings = await localDataSource.getCachedSettings();
      
      if (await networkInfo.isConnected) {
        try {
          final remoteSettings = await remoteDataSource.getSettings();
          // Update cache with latest data
          await localDataSource.cacheSettings(remoteSettings);
          return Right(remoteSettings.toEntity());
        } catch (e) {
          // Return cached settings if server fails
          if (cachedSettings != null) {
            return Right(cachedSettings.toEntity());
          }
          return _handleException(e);
        }
      } else {
        if (cachedSettings != null) {
          return Right(cachedSettings.toEntity());
        } else {
          return const Left(NetworkFailure(
            message: 'No hay conexión a internet y no hay datos en caché',
          ));
        }
      }
    } catch (e) {
      return _handleException(e);
    }
  }

  @override
  Future<Either<Failure, ProfileSettings>> updateSettings(ProfileSettings settings) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedSettings = await remoteDataSource.updateSettings(settings);
        // Update cache with new settings
        await localDataSource.cacheSettings(updatedSettings);
        return Right(updatedSettings.toEntity());
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
  Future<Either<Failure, ProfileStats>> getStats() async {
    if (await networkInfo.isConnected) {
      try {
        final stats = await remoteDataSource.getStats();
        return Right(stats.toEntity());
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
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
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
  Future<Either<Failure, void>> updatePrivacySettings({
    required bool isPrivate,
    required bool allowMessages,
    required bool allowNotifications,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Get current settings
        final currentSettingsResult = await getSettings();
        
        return currentSettingsResult.fold(
          (failure) => Left(failure),
          (currentSettings) async {
            final updatedSettings = currentSettings.copyWith(
              isPrivate: isPrivate,
              allowMessages: allowMessages,
              allowNotifications: allowNotifications,
            );
            
            final result = await updateSettings(updatedSettings);
            return result.fold(
              (failure) => Left(failure),
              (_) => const Right(null),
            );
          },
        );
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
  Future<Either<Failure, void>> deactivateAccount() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deactivateAccount();
        await localDataSource.clearCachedProfile();
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
  Future<Either<Failure, void>> deleteAccount() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteAccount();
        await localDataSource.clearCachedProfile();
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
  Future<Either<Failure, void>> reportUser({
    required String userId,
    required String reason,
  }) async {
    // TODO: Implement when API is ready
    return const Left(ServerFailure(message: 'Funcionalidad no implementada'));
  }

  @override
  Future<Either<Failure, void>> blockUser(String userId) async {
    // TODO: Implement when API is ready
    return const Left(ServerFailure(message: 'Funcionalidad no implementada'));
  }

  @override
  Future<Either<Failure, void>> unblockUser(String userId) async {
    // TODO: Implement when API is ready
    return const Left(ServerFailure(message: 'Funcionalidad no implementada'));
  }

  @override
  Future<Either<Failure, List<String>>> getBlockedUsers() async {
    // TODO: Implement when API is ready
    return const Left(ServerFailure(message: 'Funcionalidad no implementada'));
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
    } else if (e is CacheException) {
      return Left(CacheFailure(message: e.message, code: e.statusCode));
    } else {
      return Left(UnknownFailure(message: 'Error inesperado: $e'));
    }
  }
}