import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/upload_photos.dart';
import '../../domain/usecases/get_profile_stats.dart';
import '../../domain/usecases/update_profile_settings.dart';
import '../../domain/usecases/change_password.dart';

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  final ProfileStats? stats;

  const ProfileLoaded({
    required this.profile,
    this.stats,
  });

  ProfileLoaded copyWith({
    UserProfile? profile,
    ProfileStats? stats,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [profile, stats];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object> get props => [message];
}

class ProfilePhotoUploading extends ProfileState {
  final double progress;

  const ProfilePhotoUploading({required this.progress});

  @override
  List<Object> get props => [progress];
}

class ProfileUpdating extends ProfileState {}

class ProfilePasswordChanging extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final String message;

  const ProfileSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

// Cubit
class ProfileCubit extends Cubit<ProfileState> {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;
  final UploadPhotos uploadPhotos;
  final GetProfileStats getProfileStats;
  final UpdateProfileSettings updateProfileSettings;
  final ChangePassword changePassword;

  ProfileCubit({
    required this.getProfile,
    required this.updateProfile,
    required this.uploadPhotos,
    required this.getProfileStats,
    required this.updateProfileSettings,
    required this.changePassword,
  }) : super(ProfileInitial());

  // Current profile data
  UserProfile? _currentProfile;
  ProfileStats? _currentStats;
  String? _currentErrorMessage;
  bool _isUploadingPhotos = false;

  Future<void> getProfileData() async {
    emit(ProfileLoading());
    final result = await getProfile();
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) {
        _currentProfile = profile;
        emit(ProfileLoaded(profile: profile, stats: _currentStats));
      },
    );
  }

  // Actualizar perfil
  Future<void> updateProfileData({
    String? firstName,
    String? lastName,
    String? bio,
    String? career,
    String? semester,
    String? campus,
    List<String>? interests,
  }) async {
    emit(ProfileUpdating());
    final result = await updateProfile(UpdateProfileParams(
      firstName: firstName,
      lastName: lastName,
      bio: bio,
      career: career,
      semester: semester,
      campus: campus,
      interests: interests,
    ));
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (profile) {
        _currentProfile = profile;
        emit(ProfileLoaded(profile: profile, stats: _currentStats));
        emit(const ProfileSuccess(message: 'Perfil actualizado'));
      },
    );
  }

  // Subir fotos
  Future<void> uploadProfilePhotos(List<String> imagePaths) async {
    emit(const ProfilePhotoUploading(progress: 0));
    final result =
        await uploadPhotos(UploadPhotosParams(imagePaths: imagePaths));
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (photoUrls) {
        if (_currentProfile != null) {
          _currentProfile = _currentProfile!.copyWith(
            photoUrls: [..._currentProfile!.photoUrls, ...photoUrls],
          );
          emit(ProfileLoaded(profile: _currentProfile!, stats: _currentStats));
          emit(const ProfileSuccess(message: 'Fotos subidas correctamente'));
        }
      },
    );
  }

  // Cargar estadísticas
  Future<void> getProfileStatsData() async {
    final result = await getProfileStats();
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (stats) {
        _currentStats = stats;
        if (_currentProfile != null) {
          emit(ProfileLoaded(profile: _currentProfile!, stats: stats));
        }
      },
    );
  }

  // Actualizar configuración
  Future<void> updateProfileSettingsData(ProfileSettings settings) async {
    emit(ProfileUpdating());
    final result = await updateProfileSettings(
        UpdateProfileSettingsParams(settings: settings));
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (updatedSettings) {
        if (_currentProfile != null) {
          _currentProfile =
              _currentProfile!.copyWith(settings: updatedSettings);
          emit(ProfileLoaded(profile: _currentProfile!, stats: _currentStats));
          emit(const ProfileSuccess(message: 'Configuración actualizada'));
        }
      },
    );
  }

  // Cambiar contraseña
  Future<void> changeUserPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(ProfilePasswordChanging());
    final result = await changePassword(ChangePasswordParams(
      currentPassword: currentPassword,
      newPassword: newPassword,
    ));
    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (_) => emit(const ProfileSuccess(message: 'Contraseña cambiada')),
    );
  }
}
