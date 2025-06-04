import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  // Profile management
  Future<Either<Failure, UserProfile>> getProfile();
  Future<Either<Failure, UserProfile>> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
    String? career,
    String? semester,
    String? campus,
    List<String>? interests,
  });
  
  // Photo management
  Future<Either<Failure, List<String>>> uploadPhotos(List<String> imagePaths);
  Future<Either<Failure, void>> deletePhoto(String photoUrl);
  Future<Either<Failure, void>> reorderPhotos(List<String> photoUrls);
  
  // Settings management
  Future<Either<Failure, ProfileSettings>> getSettings();
  Future<Either<Failure, ProfileSettings>> updateSettings(ProfileSettings settings);
  
  // Stats
  Future<Either<Failure, ProfileStats>> getStats();
  
  // Privacy and security
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<Either<Failure, void>> updatePrivacySettings({
    required bool isPrivate,
    required bool allowMessages,
    required bool allowNotifications,
  });
  
  // Account management
  Future<Either<Failure, void>> deactivateAccount();
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, void>> reportUser({
    required String userId,
    required String reason,
  });
  Future<Either<Failure, void>> blockUser(String userId);
  Future<Either<Failure, void>> unblockUser(String userId);
  Future<Either<Failure, List<String>>> getBlockedUsers();
}