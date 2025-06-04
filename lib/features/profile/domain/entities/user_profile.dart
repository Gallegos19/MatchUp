// lib/features/profile/domain/entities/user_profile.dart - COMPLETE DEFINITION

import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
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
  final ProfileSettings settings;
  final ProfileStats stats;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isVerified;

  const UserProfile({
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

  // Computed properties
  String get fullName => '$firstName $lastName'.trim();
  String get displayName => fullName.isNotEmpty ? fullName : email;
  bool get hasPhotos => photoUrls.isNotEmpty;
  String get primaryPhoto => photoUrls.isNotEmpty ? photoUrls.first : '';

  UserProfile copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? bio,
    int? age,
    String? career,
    String? semester,
    String? campus,
    List<String>? interests,
    List<String>? photoUrls,
    ProfileSettings? settings,
    ProfileStats? stats,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isVerified,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,
      age: age ?? this.age,
      career: career ?? this.career,
      semester: semester ?? this.semester,
      campus: campus ?? this.campus,
      interests: interests ?? this.interests,
      photoUrls: photoUrls ?? this.photoUrls,
      settings: settings ?? this.settings,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        bio,
        age,
        career,
        semester,
        campus,
        interests,
        photoUrls,
        settings,
        stats,
        createdAt,
        updatedAt,
        isActive,
        isVerified,
      ];
}

class ProfileSettings extends Equatable {
  final bool showAge;
  final bool showCareer;
  final bool showCampus;
  final bool allowMessages;
  final bool allowNotifications;
  final bool isPrivate;
  final int maxDistance;
  final AgeRange ageRange;

  const ProfileSettings({
    this.showAge = true,
    this.showCareer = true,
    this.showCampus = true,
    this.allowMessages = true,
    this.allowNotifications = true,
    this.isPrivate = false,
    this.maxDistance = 50,
    this.ageRange = const AgeRange(min: 18, max: 30),
  });

  ProfileSettings copyWith({
    bool? showAge,
    bool? showCareer,
    bool? showCampus,
    bool? allowMessages,
    bool? allowNotifications,
    bool? isPrivate,
    int? maxDistance,
    AgeRange? ageRange,
  }) {
    return ProfileSettings(
      showAge: showAge ?? this.showAge,
      showCareer: showCareer ?? this.showCareer,
      showCampus: showCampus ?? this.showCampus,
      allowMessages: allowMessages ?? this.allowMessages,
      allowNotifications: allowNotifications ?? this.allowNotifications,
      isPrivate: isPrivate ?? this.isPrivate,
      maxDistance: maxDistance ?? this.maxDistance,
      ageRange: ageRange ?? this.ageRange,
    );
  }

  @override
  List<Object> get props => [
        showAge,
        showCareer,
        showCampus,
        allowMessages,
        allowNotifications,
        isPrivate,
        maxDistance,
        ageRange,
      ];
}

class ProfileStats extends Equatable {
  final int matchesCount;
  final int likesGiven;
  final int likesReceived;
  final int superLikesReceived;
  final int profileViews;
  final int eventsJoined;
  final int studyGroupsJoined;

  const ProfileStats({
    this.matchesCount = 0,
    this.likesGiven = 0,
    this.likesReceived = 0,
    this.superLikesReceived = 0,
    this.profileViews = 0,
    this.eventsJoined = 0,
    this.studyGroupsJoined = 0,
  });

  ProfileStats copyWith({
    int? matchesCount,
    int? likesGiven,
    int? likesReceived,
    int? superLikesReceived,
    int? profileViews,
    int? eventsJoined,
    int? studyGroupsJoined,
  }) {
    return ProfileStats(
      matchesCount: matchesCount ?? this.matchesCount,
      likesGiven: likesGiven ?? this.likesGiven,
      likesReceived: likesReceived ?? this.likesReceived,
      superLikesReceived: superLikesReceived ?? this.superLikesReceived,
      profileViews: profileViews ?? this.profileViews,
      eventsJoined: eventsJoined ?? this.eventsJoined,
      studyGroupsJoined: studyGroupsJoined ?? this.studyGroupsJoined,
    );
  }

  @override
  List<Object> get props => [
        matchesCount,
        likesGiven,
        likesReceived,
        superLikesReceived,
        profileViews,
        eventsJoined,
        studyGroupsJoined,
      ];
}

class AgeRange extends Equatable {
  final int min;
  final int max;

  const AgeRange({
    required this.min,
    required this.max,
  });

  AgeRange copyWith({
    int? min,
    int? max,
  }) {
    return AgeRange(
      min: min ?? this.min,
      max: max ?? this.max,
    );
  }

  @override
  List<Object> get props => [min, max];
}