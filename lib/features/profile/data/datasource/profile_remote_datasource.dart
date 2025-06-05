import 'package:dio/dio.dart';
import 'package:matchup/core/services/cloudinary_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_profile_model.dart';
import '../../domain/entities/user_profile.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? career,
    String? semester,
    String? campus,
    List<String>? interests,
    List<String>? photoUrls,
  });
  Future<List<String>> uploadPhotos(List<String> imagePaths);
  Future<void> deletePhoto(String photoUrl);
  Future<void> reorderPhotos(List<String> photoUrls);
  Future<ProfileSettingsModel> getSettings();
  Future<ProfileSettingsModel> updateSettings(ProfileSettings settings);
  Future<ProfileStatsModel> getStats();
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> deactivateAccount();
  Future<void> deleteAccount();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});
  

  @override
  Future<UserProfileModel> getProfile() async {
    try {
      final response = await dio.get('users/profile');

      if (response.statusCode == 200) {
        final userData = response.data['data'] ?? response.data;
        return UserProfileModel.fromJson(userData);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al obtener perfil',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<UserProfileModel> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? career,
    String? semester,
    String? campus,
    List<String>? interests,
    List<String>? photoUrls,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (bio != null) data['bio'] = bio;
      if (career != null) data['career'] = career;
      if (semester != null) data['semester'] = semester;
      if (campus != null) data['campus'] = campus;
      if (interests != null) data['interests'] = interests;
      if (photoUrls != null) data['photoUrls'] = photoUrls;

      final response = await dio.put('users/profile', data: data);

      if (response.statusCode == 200) {
        final userData = response.data['data'] ?? response.data;
        return UserProfileModel.fromJson(userData);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al actualizar perfil',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

@override
  Future<List<String>> uploadPhotos(List<String> imagePaths) async {
    try {
      // Subir imágenes a Cloudinary primero
      final cloudinaryService = CloudinaryService(dio: dio);
      final photoUrls = await cloudinaryService.uploadMultipleImages(
        imagePaths,
        folder: 'matchup/profiles',
      );

      // Luego actualizar el perfil con las URLs
      final response = await dio.put('users/profile', data: {
        'photoUrls': photoUrls,
      });

      if (response.statusCode == 200) {
        return photoUrls;
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al actualizar fotos en perfil',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deletePhoto(String photoUrl) async {
    try {
      final response = await dio.delete(
        'users/photos',
        data: {'photoUrl': photoUrl},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al eliminar foto',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> reorderPhotos(List<String> photoUrls) async {
    try {
      final response = await dio.put(
        'users/photos/reorder',
        data: {'photoUrls': photoUrls},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al reordenar fotos',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ProfileSettingsModel> getSettings() async {
    try {
      final response = await dio.get('users/settings');

      if (response.statusCode == 200) {
        final settingsData = response.data['data'] ?? response.data;
        return ProfileSettingsModel.fromJson(settingsData);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al obtener configuración',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ProfileSettingsModel> updateSettings(ProfileSettings settings) async {
    try {
      final response = await dio.put(
        'users/settings',
        data: {
          'showAge': settings.showAge,
          'showCareer': settings.showCareer,
          'showCampus': settings.showCampus,
          'allowMessages': settings.allowMessages,
          'allowNotifications': settings.allowNotifications,
          'isPrivate': settings.isPrivate,
          'maxDistance': settings.maxDistance,
          'ageRange': {
            'min': settings.ageRange.min,
            'max': settings.ageRange.max,
          },
        },
      );

      if (response.statusCode == 200) {
        final settingsData = response.data['data'] ?? response.data;
        return ProfileSettingsModel.fromJson(settingsData);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al actualizar configuración',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ProfileStatsModel> getStats() async {
    try {
      final response = await dio.get('users/stats');

      if (response.statusCode == 200) {
        final statsData = response.data['data'] ?? response.data;
        return ProfileStatsModel.fromJson(statsData);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al obtener estadísticas',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await dio.put(
        'users/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al cambiar contraseña',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deactivateAccount() async {
    try {
      final response = await dio.patch('users/deactivate');

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al desactivar cuenta',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final response = await dio.delete('users/account');

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al eliminar cuenta',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Tiempo de espera agotado',
          statusCode: e.response?.statusCode,
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? 'Error del servidor';

        switch (statusCode) {
          case 400:
            return ValidationException(message: message, statusCode: statusCode);
          case 401:
            return AuthenticationException(message: message, statusCode: statusCode);
          case 403:
            return UnauthorizedException(message: message, statusCode: statusCode);
          case 404:
            return NotFoundException(message: message, statusCode: statusCode);
          default:
            return ServerException(message: message, statusCode: statusCode);
        }

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Error de conexión. Verifica tu internet',
          statusCode: null,
        );

      default:
        return ServerException(
          message: 'Error inesperado: ${e.message}',
          statusCode: e.response?.statusCode,
        );
    }
  }
}
