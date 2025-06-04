// lib/features/discovery/data/models/profile_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/profile.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class ProfileModel extends Profile {
  const ProfileModel({
    required String id,
    required String userId,
    required String name,
    required int age,
    required String career,
    required String semester,
    required String campus,
    String? bio,
    List<String> interests = const [],
    List<String> photoUrls = const [],
    double? distance,
    bool isActive = true,
    required DateTime lastSeen,
    bool isVerified = false,
  }) : super(
          id: id,
          userId: userId,
          name: name,
          age: age,
          career: career,
          semester: semester,
          campus: campus,
          bio: bio,
          interests: interests,
          photoUrls: photoUrls,
          distance: distance,
          isActive: isActive,
          lastSeen: lastSeen,
          isVerified: isVerified,
        );

  factory ProfileModel.fromJson(Map<String, dynamic> json) => _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);

  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      id: profile.id,
      userId: profile.userId,
      name: profile.name,
      age: profile.age,
      career: profile.career,
      semester: profile.semester,
      campus: profile.campus,
      bio: profile.bio,
      interests: profile.interests,
      photoUrls: profile.photoUrls,
      distance: profile.distance,
      isActive: profile.isActive,
      lastSeen: profile.lastSeen,
      isVerified: profile.isVerified,
    );
  }

  Profile toEntity() {
    return Profile(
      id: id,
      userId: userId,
      name: name,
      age: age,
      career: career,
      semester: semester,
      campus: campus,
      bio: bio,
      interests: interests,
      photoUrls: photoUrls,
      distance: distance,
      isActive: isActive,
      lastSeen: lastSeen,
      isVerified: isVerified,
    );
  }
}

