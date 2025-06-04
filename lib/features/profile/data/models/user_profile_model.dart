// lib/features/profile/data/models/user_profile_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@JsonSerializable()
class UserProfileModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? bio;
  final int? age;
  final String? career;
  final String? semester;
  final String? campus;
  final List<String> interests;
  final List<String> photoUrls;
  final ProfileSettingsModel settings;
  final ProfileStatsModel stats;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isVerified;

  UserProfileModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.bio,
    this.age,
    this.career,
    this.semester,
    this.campus,
    this.interests = const [],
    this.photoUrls = const [],
    required this.settings,
    required this.stats,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isVerified = false,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);

  // Conversión desde entidad del dominio
  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      bio: entity.bio,
      age: entity.age,
      career: entity.career,
      semester: entity.semester,
      campus: entity.campus,
      interests: entity.interests,
      photoUrls: entity.photoUrls,
      settings: ProfileSettingsModel.fromEntity(entity.settings),
      stats: ProfileStatsModel.fromEntity(entity.stats),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      isVerified: entity.isVerified,
    );
  }

  // Conversión hacia entidad del dominio
  UserProfile toEntity() {
    return UserProfile(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      bio: bio,
      age: age,
      career: career,
      semester: semester,
      campus: campus,
      interests: interests,
      photoUrls: photoUrls,
      settings: settings.toEntity(),
      stats: stats.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      isVerified: isVerified,
    );
  }
}

@JsonSerializable()
class ProfileSettingsModel {
  final bool showAge;
  final bool showCareer;
  final bool showCampus;
  final bool allowMessages;
  final bool allowNotifications;
  final bool isPrivate;
  final int maxDistance;
  final AgeRangeModel ageRange;

  ProfileSettingsModel({
    this.showAge = true,
    this.showCareer = true,
    this.showCampus = true,
    this.allowMessages = true,
    this.allowNotifications = true,
    this.isPrivate = false,
    this.maxDistance = 50,
    required this.ageRange,
  });

  factory ProfileSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileSettingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileSettingsModelToJson(this);

  factory ProfileSettingsModel.fromEntity(ProfileSettings entity) {
    return ProfileSettingsModel(
      showAge: entity.showAge,
      showCareer: entity.showCareer,
      showCampus: entity.showCampus,
      allowMessages: entity.allowMessages,
      allowNotifications: entity.allowNotifications,
      isPrivate: entity.isPrivate,
      maxDistance: entity.maxDistance,
      ageRange: AgeRangeModel.fromEntity(entity.ageRange),
    );
  }

  ProfileSettings toEntity() {
    return ProfileSettings(
      showAge: showAge,
      showCareer: showCareer,
      showCampus: showCampus,
      allowMessages: allowMessages,
      allowNotifications: allowNotifications,
      isPrivate: isPrivate,
      maxDistance: maxDistance,
      ageRange: ageRange.toEntity(),
    );
  }
}

@JsonSerializable()
class ProfileStatsModel {
  final int matchesCount;
  final int likesGiven;
  final int likesReceived;
  final int superLikesReceived;
  final int profileViews;
  final int eventsJoined;
  final int studyGroupsJoined;

  ProfileStatsModel({
    this.matchesCount = 0,
    this.likesGiven = 0,
    this.likesReceived = 0,
    this.superLikesReceived = 0,
    this.profileViews = 0,
    this.eventsJoined = 0,
    this.studyGroupsJoined = 0,
  });

  factory ProfileStatsModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileStatsModelToJson(this);

  factory ProfileStatsModel.fromEntity(ProfileStats entity) {
    return ProfileStatsModel(
      matchesCount: entity.matchesCount,
      likesGiven: entity.likesGiven,
      likesReceived: entity.likesReceived,
      superLikesReceived: entity.superLikesReceived,
      profileViews: entity.profileViews,
      eventsJoined: entity.eventsJoined,
      studyGroupsJoined: entity.studyGroupsJoined,
    );
  }

  ProfileStats toEntity() {
    return ProfileStats(
      matchesCount: matchesCount,
      likesGiven: likesGiven,
      likesReceived: likesReceived,
      superLikesReceived: superLikesReceived,
      profileViews: profileViews,
      eventsJoined: eventsJoined,
      studyGroupsJoined: studyGroupsJoined,
    );
  }
}

@JsonSerializable()
class AgeRangeModel {
  final int min;
  final int max;

  AgeRangeModel({
    required this.min,
    required this.max,
  });

  factory AgeRangeModel.fromJson(Map<String, dynamic> json) =>
      _$AgeRangeModelFromJson(json);

  Map<String, dynamic> toJson() => _$AgeRangeModelToJson(this);

  factory AgeRangeModel.fromEntity(AgeRange entity) {
    return AgeRangeModel(
      min: entity.min,
      max: entity.max,
    );
  }

  AgeRange toEntity() {
    return AgeRange(
      min: min,
      max: max,
    );
  }
}