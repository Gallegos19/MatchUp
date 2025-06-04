// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      career: json['career'] as String,
      semester: json['semester'] as String,
      campus: json['campus'] as String,
      bio: json['bio'] as String?,
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      photoUrls: (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      distance: (json['distance'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      isVerified: json['isVerified'] as bool? ?? false,
    );

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'age': instance.age,
      'career': instance.career,
      'semester': instance.semester,
      'campus': instance.campus,
      'bio': instance.bio,
      'interests': instance.interests,
      'photoUrls': instance.photoUrls,
      'distance': instance.distance,
      'isActive': instance.isActive,
      'lastSeen': instance.lastSeen.toIso8601String(),
      'isVerified': instance.isVerified,
    };
