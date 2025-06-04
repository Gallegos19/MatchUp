import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String career,
    required int semester,
    required String campus,
  });

  Future<void> logout();
  Future<UserModel> getCurrentUser();
  Future<void> verifyEmail(String token);
  Future<UserModel> updateProfile({
    String? bio,
    List<String>? interests,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        'auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final userJson = data['user'];
        final token = data['token'];

        // Store token for future requests
        dio.options.headers['Authorization'] = 'Bearer $token';
        
        return UserModel.fromJson(userJson).copyWithToken(token);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error en el servidor',
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
  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String career,
    required int semester,
    required String campus,
  }) async {
    try {
      final response = await dio.post(
        'auth/register',
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'dateOfBirth': dateOfBirth,
          'career': career,
          'semester': semester,
          'campus': campus,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final userJson = data['user'] ?? data;
        final token = data['token'];

        if (token != null) {
          dio.options.headers['Authorization'] = 'Bearer $token';
          return UserModel.fromJson(userJson).copyWithToken(token);
        }
        
        return UserModel.fromJson(userJson);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error en el registro',
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
  Future<void> verifyEmail(String token) async {
    try {
      final response = await dio.get('auth/verify-email/$token');

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al verificar email',
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
  Future<UserModel> updateProfile({
    String? bio,
    List<String>? interests,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (bio != null) data['bio'] = bio;
      if (interests != null) data['interests'] = interests;

      final response = await dio.put('users/profile', data: data);

      if (response.statusCode == 200) {
        final userData = response.data['data'] ?? response.data;
        return UserModel.fromJson(userData);
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
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dio.get('users/profile');

      if (response.statusCode == 200) {
        final userData = response.data['data'] ?? response.data;
        return UserModel.fromJson(userData);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al obtener usuario',
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
  Future<void> logout() async {
    try {
      // Remove authorization header
      dio.options.headers.remove('Authorization');
      // In this API, logout seems to be handled client-side
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
          case 409:
            return ConflictException(message: message, statusCode: statusCode);
          default:
            return ServerException(message: message, statusCode: statusCode);
        }

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Error de conexión. Verifica tu internet',
          statusCode: null,
        );

      case DioExceptionType.cancel:
        return ServerException(
          message: 'Solicitud cancelada',
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