import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCachedUser();
  Future<void> cacheToken(String token);
  Future<String?> getCachedToken();
  Future<void> clearCachedToken();
  Future<void> cacheRefreshToken(String refreshToken);
  Future<String?> getCachedRefreshToken();
  Future<void> clearCachedRefreshToken();
  Future<bool> isLoggedIn();
  Future<void> clearAllAuthData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _userKey = 'CACHED_USER';
  static const String _tokenKey = 'AUTH_TOKEN';
  static const String _refreshTokenKey = 'REFRESH_TOKEN';
  static const String _isLoggedInKey = 'IS_LOGGED_IN';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      final success = await sharedPreferences.setString(_userKey, userJson);
      
      if (!success) {
        throw CacheException(
          message: 'Error al guardar usuario en caché',
        );
      }
      
      // Mark user as logged in
      await sharedPreferences.setBool(_isLoggedInKey, true);
    } catch (e) {
      throw CacheException(
        message: 'Error al guardar usuario: $e',
      );
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJsonString = sharedPreferences.getString(_userKey);
      
      if (userJsonString != null) {
        final userJson = json.decode(userJsonString);
        return UserModel.fromJson(userJson);
      }
      
      return null;
    } catch (e) {
      throw CacheException(
        message: 'Error al obtener usuario en caché: $e',
      );
    }
  }

  @override
  Future<void> clearCachedUser() async {
    try {
      await sharedPreferences.remove(_userKey);
      await sharedPreferences.setBool(_isLoggedInKey, false);
    } catch (e) {
      throw CacheException(
        message: 'Error al limpiar usuario en caché: $e',
      );
    }
  }

  @override
  Future<void> cacheToken(String token) async {
    try {
      final success = await sharedPreferences.setString(_tokenKey, token);
      
      if (!success) {
        throw CacheException(
          message: 'Error al guardar token en caché',
        );
      }
    } catch (e) {
      throw CacheException(
        message: 'Error al guardar token: $e',
      );
    }
  }

  @override
  Future<String?> getCachedToken() async {
    try {
      return sharedPreferences.getString(_tokenKey);
    } catch (e) {
      throw CacheException(
        message: 'Error al obtener token en caché: $e',
      );
    }
  }

  @override
  Future<void> clearCachedToken() async {
    try {
      await sharedPreferences.remove(_tokenKey);
    } catch (e) {
      throw CacheException(
        message: 'Error al limpiar token en caché: $e',
      );
    }
  }

  @override
  Future<void> cacheRefreshToken(String refreshToken) async {
    try {
      final success = await sharedPreferences.setString(_refreshTokenKey, refreshToken);
      
      if (!success) {
        throw CacheException(
          message: 'Error al guardar refresh token en caché',
        );
      }
    } catch (e) {
      throw CacheException(
        message: 'Error al guardar refresh token: $e',
      );
    }
  }

  @override
  Future<String?> getCachedRefreshToken() async {
    try {
      return sharedPreferences.getString(_refreshTokenKey);
    } catch (e) {
      throw CacheException(
        message: 'Error al obtener refresh token en caché: $e',
      );
    }
  }

  @override
  Future<void> clearCachedRefreshToken() async {
    try {
      await sharedPreferences.remove(_refreshTokenKey);
    } catch (e) {
      throw CacheException(
        message: 'Error al limpiar refresh token en caché: $e',
      );
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final isLoggedIn = sharedPreferences.getBool(_isLoggedInKey) ?? false;
      final hasToken = sharedPreferences.getString(_tokenKey) != null;
      
      return isLoggedIn && hasToken;
    } catch (e) {
      throw CacheException(
        message: 'Error al verificar estado de login: $e',
      );
    }
  }

  @override
  Future<void> clearAllAuthData() async {
    try {
      await Future.wait([
        clearCachedUser(),
        clearCachedToken(),
        clearCachedRefreshToken(),
      ]);
    } catch (e) {
      throw CacheException(
        message: 'Error al limpiar datos de autenticación: $e',
      );
    }
  }
}