// lib/features/authentication/data/datasource/auth_remote_datasource.dart
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
    required String name,
  });

  Future<void> logout();

  Future<UserModel> getCurrentUser();

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> deleteAccount();

  Future<String> refreshToken();
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
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final userJson = data['user'];
        final token = data['token'];

        // Inyectamos el token en el modelo
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
    required String name,
  }) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );

      if (response.statusCode == 201) {
        final userData = response.data['user'];
        return UserModel.fromJson(userData);
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
  Future<void> logout() async {
    try {
      final response = await dio.post('/auth/logout');

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al cerrar sesión',
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
      final response = await dio.get('/auth/me');

      if (response.statusCode == 200) {
        final userData = response.data['user'];
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
  Future<void> forgotPassword({required String email}) async {
    try {
      final response = await dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al enviar email',
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
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await dio.post(
        '/auth/reset-password',
        data: {
          'token': token,
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
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await dio.put(
        '/auth/change-password',
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
  Future<void> deleteAccount() async {
    try {
      final response = await dio.delete('/auth/account');

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

  @override
  Future<String> refreshToken() async {
    try {
      final response = await dio.post('/auth/refresh-token');

      if (response.statusCode == 200) {
        return response.data['accessToken'];
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al renovar token',
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
            return ValidationException(
                message: message, statusCode: statusCode);
          case 401:
            return AuthenticationException(
                message: message, statusCode: statusCode);
          case 403:
            return UnauthorizedException(
                message: message, statusCode: statusCode);
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
