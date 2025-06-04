import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/upload_photos.dart';
import '../../domain/usecases/get_profile_stats.dart';
import '../../domain/usecases/update_profile_settings.dart';
import '../../domain/usecases/change_password.dart';

enum ProfileViewState { initial, loading, loaded, error }

class ProfileViewModel extends ChangeNotifier {
  final GetProfile getProfileUseCase;
  final UpdateProfile updateProfileUseCase;
  final UploadPhotos uploadPhotosUseCase;
  final GetProfileStats getProfileStatsUseCase;
  final UpdateProfileSettings updateProfileSettingsUseCase;
  final ChangePassword changePasswordUseCase;

  ProfileViewModel({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.uploadPhotosUseCase,
    required this.getProfileStatsUseCase,
    required this.updateProfileSettingsUseCase,
    required this.changePasswordUseCase,
  });

  // State management
  ProfileViewState _state = ProfileViewState.initial;
  UserProfile? _profile;
  ProfileStats? _stats;
  String? _errorMessage;

  // Photo upload state
  bool _isUploadingPhotos = false;
  double _uploadProgress = 0.0;

  // Settings state
  bool _isUpdatingSettings = false;

  // Password change state
  bool _isChangingPassword = false;

  // Getters
  ProfileViewState get state => _state;
  UserProfile? get profile => _profile;
  ProfileStats? get stats => _stats;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ProfileViewState.loading;
  bool get isUploadingPhotos => _isUploadingPhotos;
  double get uploadProgress => _uploadProgress;
  bool get isUpdatingSettings => _isUpdatingSettings;
  bool get isChangingPassword => _isChangingPassword;

  // Load profile
  Future<void> loadProfile() async {
    _setState(ProfileViewState.loading);

    final result = await getProfileUseCase();

    result.fold(
      (failure) {
        _errorMessage = _getFailureMessage(failure);
        _setState(ProfileViewState.error);
      },
      (profile) {
        _profile = profile;
        _errorMessage = null;
        _setState(ProfileViewState.loaded);
      },
    );
  }

  // Update profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? career,
    String? semester,
    String? campus,
    List<String>? interests,
  }) async {
    _setState(ProfileViewState.loading);

    final result = await updateProfileUseCase(UpdateProfileParams(
      firstName: firstName,
      lastName: lastName,
      bio: bio,
      career: career,
      semester: semester,
      campus: campus,
      interests: interests,
    ));

    return result.fold(
      (failure) {
        _errorMessage = _getFailureMessage(failure);
        _setState(ProfileViewState.error);
        return false;
      },
      (updatedProfile) {
        _profile = updatedProfile;
        _errorMessage = null;
        _setState(ProfileViewState.loaded);
        return true;
      },
    );
  }

  // Upload photos
  Future<bool> uploadPhotos(List<String> imagePaths) async {
    _isUploadingPhotos = true;
    _uploadProgress = 0.0;
    notifyListeners();

    final result = await uploadPhotosUseCase(UploadPhotosParams(imagePaths: imagePaths));

    return result.fold(
      (failure) {
        _errorMessage = _getFailureMessage(failure);
        _isUploadingPhotos = false;
        _uploadProgress = 0.0;
        notifyListeners();
        return false;
      },
      (photoUrls) {
        // Update profile with new photos
        if (_profile != null) {
          _profile = _profile!.copyWith(
            photoUrls: [..._profile!.photoUrls, ...photoUrls],
          );
        }
        _isUploadingPhotos = false;
        _uploadProgress = 1.0;
        notifyListeners();
        return true;
      },
    );
  }

  // Load profile stats
  Future<void> loadStats() async {
    final result = await getProfileStatsUseCase();

    result.fold(
      (failure) {
        _errorMessage = _getFailureMessage(failure);
      },
      (stats) {
        _stats = stats;
        notifyListeners();
      },
    );
  }

  // Update settings
  Future<bool> updateSettings(ProfileSettings settings) async {
    _isUpdatingSettings = true;
    notifyListeners();

    final result = await updateProfileSettingsUseCase(
      UpdateProfileSettingsParams(settings: settings),
    );

    return result.fold(
      (failure) {
        _errorMessage = _getFailureMessage(failure);
        _isUpdatingSettings = false;
        notifyListeners();
        return false;
      },
      (updatedSettings) {
        if (_profile != null) {
          _profile = _profile!.copyWith(settings: updatedSettings);
        }
        _isUpdatingSettings = false;
        notifyListeners();
        return true;
      },
    );
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isChangingPassword = true;
    notifyListeners();

    final result = await changePasswordUseCase(ChangePasswordParams(
      currentPassword: currentPassword,
      newPassword: newPassword,
    ));

    return result.fold(
      (failure) {
        _errorMessage = _getFailureMessage(failure);
        _isChangingPassword = false;
        notifyListeners();
        return false;
      },
      (_) {
        _isChangingPassword = false;
        notifyListeners();
        return true;
      },
    );
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == ProfileViewState.error) {
      _setState(ProfileViewState.loaded);
    }
  }

  // Refresh profile
  Future<void> refreshProfile() async {
    await loadProfile();
    await loadStats();
  }

  // Private methods
  void _setState(ProfileViewState newState) {
    _state = newState;
    notifyListeners();
  }

  String _getFailureMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'Error de conexión. Verifica tu internet';
      case ServerFailure:
        return 'Error del servidor. Intenta más tarde';
      case UnauthorizedFailure:
        return 'Sesión expirada. Inicia sesión nuevamente';
      case ValidationFailure:
        return failure.message;
      case UserNotFoundFailure:
        return 'Perfil no encontrado';
      case TimeoutFailure:
        return 'Tiempo de espera agotado. Intenta nuevamente';
      case CacheFailure:
        return 'Error al guardar datos localmente';
      default:
        return failure.message.isNotEmpty 
            ? failure.message 
            : 'Ha ocurrido un error inesperado';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
