import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<void> cacheProfile(UserProfileModel profile);
  Future<UserProfileModel?> getCachedProfile();
  Future<void> clearCachedProfile();
  Future<void> cacheSettings(ProfileSettingsModel settings);
  Future<ProfileSettingsModel?> getCachedSettings();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _profileKey = 'CACHED_PROFILE';
  static const String _settingsKey = 'CACHED_SETTINGS';

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheProfile(UserProfileModel profile) async {
    try {
      final profileJson = json.encode(profile.toJson());
      final success = await sharedPreferences.setString(_profileKey, profileJson);
      
      if (!success) {
        throw CacheException(
          message: 'Error al guardar perfil en caché',
        );
      }
    } catch (e) {
      throw CacheException(
        message: 'Error al guardar perfil: $e',
      );
    }
  }

  @override
  Future<UserProfileModel?> getCachedProfile() async {
    try {
      final profileJsonString = sharedPreferences.getString(_profileKey);
      
      if (profileJsonString != null) {
        final profileJson = json.decode(profileJsonString);
        return UserProfileModel.fromJson(profileJson);
      }
      
      return null;
    } catch (e) {
      throw CacheException(
        message: 'Error al obtener perfil en caché: $e',
      );
    }
  }

  @override
  Future<void> clearCachedProfile() async {
    try {
      await sharedPreferences.remove(_profileKey);
    } catch (e) {
      throw CacheException(
        message: 'Error al limpiar perfil en caché: $e',
      );
    }
  }

  @override
  Future<void> cacheSettings(ProfileSettingsModel settings) async {
    try {
      final settingsJson = json.encode(settings.toJson());
      final success = await sharedPreferences.setString(_settingsKey, settingsJson);
      
      if (!success) {
        throw CacheException(
          message: 'Error al guardar configuración en caché',
        );
      }
    } catch (e) {
      throw CacheException(
        message: 'Error al guardar configuración: $e',
      );
    }
  }

  @override
  Future<ProfileSettingsModel?> getCachedSettings() async {
    try {
      final settingsJsonString = sharedPreferences.getString(_settingsKey);
      
      if (settingsJsonString != null) {
        final settingsJson = json.decode(settingsJsonString);
        return ProfileSettingsModel.fromJson(settingsJson);
      }
      
      return null;
    } catch (e) {
      throw CacheException(
        message: 'Error al obtener configuración en caché: $e',
      );
    }
  }
}