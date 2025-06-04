// lib/features/discovery/data/datasource/discovery_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../models/profile_model.dart';

abstract class DiscoveryRemoteDataSource {
  Future<List<ProfileModel>> getProfiles({
    DiscoveryFilters? filters,
    int page = 1,
    int limit = 10,
  });

  Future<bool> swipeProfile({
    required String profileId,
    required SwipeAction action,
  });

  Future<ProfileModel> getProfileDetails({
    required String profileId,
  });

  Future<void> reportProfile({
    required String profileId,
    required String reason,
  });

  Future<void> blockProfile({
    required String profileId,
  });

  Future<List<ProfileModel>> getLikedProfiles({
    int page = 1,
    int limit = 10,
  });

  Future<List<ProfileModel>> getPassedProfiles({
    int page = 1,
    int limit = 10,
  });

  Future<void> undoLastSwipe();
}

class DiscoveryRemoteDataSourceImpl implements DiscoveryRemoteDataSource {
  final Dio dio;

  DiscoveryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProfileModel>> getProfiles({
    DiscoveryFilters? filters,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      // Add filters to query params
      if (filters != null) {
        if (filters.minAge != null) queryParams['min_age'] = filters.minAge;
        if (filters.maxAge != null) queryParams['max_age'] = filters.maxAge;
        if (filters.careers != null) queryParams['careers'] = filters.careers;
        if (filters.semesters != null) queryParams['semesters'] = filters.semesters;
        if (filters.campuses != null) queryParams['campuses'] = filters.campuses;
        if (filters.maxDistance != null) queryParams['max_distance'] = filters.maxDistance;
        if (filters.interests != null) queryParams['interests'] = filters.interests;
      }

      final response = await dio.get(
        '/discovery/profiles',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> profilesJson = response.data['profiles'];
        return profilesJson
            .map((json) => ProfileModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al obtener perfiles',
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
  Future<bool> swipeProfile({
    required String profileId,
    required SwipeAction action,
  }) async {
    try {
      final response = await dio.post(
        '/discovery/swipe',
        data: {
          'profile_id': profileId,
          'action': action.toString().split('.').last,
        },
      );

      if (response.statusCode == 200) {
        return response.data['is_match'] ?? false;
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al hacer swipe',
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
  Future<ProfileModel> getProfileDetails({
    required String profileId,
  }) async {
    try {
      final response = await dio.get('/discovery/profiles/$profileId');

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data['profile']);
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
  Future<void> reportProfile({
    required String profileId,
    required String reason,
  }) async {
    try {
      final response = await dio.post(
        '/discovery/report',
        data: {
          'profile_id': profileId,
          'reason': reason,
        },
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al reportar perfil',
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
  Future<void> blockProfile({
    required String profileId,
  }) async {
    try {
      final response = await dio.post(
        '/discovery/block',
        data: {'profile_id': profileId},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al bloquear perfil',
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
  Future<List<ProfileModel>> getLikedProfiles({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '/discovery/liked',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> profilesJson = response.data['profiles'];
        return profilesJson
            .map((json) => ProfileModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al obtener likes',
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
  Future<List<ProfileModel>> getPassedProfiles({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await dio.get(
        '/discovery/passed',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> profilesJson = response.data['profiles'];
        return profilesJson
            .map((json) => ProfileModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al obtener perfiles pasados',
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
  Future<void> undoLastSwipe() async {
    try {
      final response = await dio.post('/discovery/undo');

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al deshacer swipe',
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