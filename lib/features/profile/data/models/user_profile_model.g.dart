// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) =>
    UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      bio: json['bio'] as String?,
      age: (json['age'] as num?)?.toInt(),
      career: json['career'] as String?,
      semester: json['semester'] as String?,
      campus: json['campus'] as String?,
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      photoUrls: (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      settings: ProfileSettingsModel.fromJson(
          json['settings'] as Map<String, dynamic>),
      stats: ProfileStatsModel.fromJson(json['stats'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      isVerified: json['isVerified'] as bool? ?? false,
    );

Map<String, dynamic> _$UserProfileModelToJson(UserProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'bio': instance.bio,
      'age': instance.age,
      'career': instance.career,
      'semester': instance.semester,
      'campus': instance.campus,
      'interests': instance.interests,
      'photoUrls': instance.photoUrls,
      'settings': instance.settings,
      'stats': instance.stats,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isActive': instance.isActive,
      'isVerified': instance.isVerified,
    };

ProfileSettingsModel _$ProfileSettingsModelFromJson(
        Map<String, dynamic> json) =>
    ProfileSettingsModel(
      showAge: json['showAge'] as bool? ?? true,
      showCareer: json['showCareer'] as bool? ?? true,
      showCampus: json['showCampus'] as bool? ?? true,
      allowMessages: json['allowMessages'] as bool? ?? true,
      allowNotifications: json['allowNotifications'] as bool? ?? true,
      isPrivate: json['isPrivate'] as bool? ?? false,
      maxDistance: (json['maxDistance'] as num?)?.toInt() ?? 50,
      ageRange:
          AgeRangeModel.fromJson(json['ageRange'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProfileSettingsModelToJson(
        ProfileSettingsModel instance) =>
    <String, dynamic>{
      'showAge': instance.showAge,
      'showCareer': instance.showCareer,
      'showCampus': instance.showCampus,
      'allowMessages': instance.allowMessages,
      'allowNotifications': instance.allowNotifications,
      'isPrivate': instance.isPrivate,
      'maxDistance': instance.maxDistance,
      'ageRange': instance.ageRange,
    };

ProfileStatsModel _$ProfileStatsModelFromJson(Map<String, dynamic> json) =>
    ProfileStatsModel(
      matchesCount: (json['matchesCount'] as num?)?.toInt() ?? 0,
      likesGiven: (json['likesGiven'] as num?)?.toInt() ?? 0,
      likesReceived: (json['likesReceived'] as num?)?.toInt() ?? 0,
      superLikesReceived: (json['superLikesReceived'] as num?)?.toInt() ?? 0,
      profileViews: (json['profileViews'] as num?)?.toInt() ?? 0,
      eventsJoined: (json['eventsJoined'] as num?)?.toInt() ?? 0,
      studyGroupsJoined: (json['studyGroupsJoined'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ProfileStatsModelToJson(ProfileStatsModel instance) =>
    <String, dynamic>{
      'matchesCount': instance.matchesCount,
      'likesGiven': instance.likesGiven,
      'likesReceived': instance.likesReceived,
      'superLikesReceived': instance.superLikesReceived,
      'profileViews': instance.profileViews,
      'eventsJoined': instance.eventsJoined,
      'studyGroupsJoined': instance.studyGroupsJoined,
    };

AgeRangeModel _$AgeRangeModelFromJson(Map<String, dynamic> json) =>
    AgeRangeModel(
      min: (json['min'] as num).toInt(),
      max: (json['max'] as num).toInt(),
    );

Map<String, dynamic> _$AgeRangeModelToJson(AgeRangeModel instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
    };
