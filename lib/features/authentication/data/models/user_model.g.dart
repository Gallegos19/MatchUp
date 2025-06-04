// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      age: (json['age'] as num?)?.toInt(),
      career: json['career'] as String?,
      semester: json['semester'] as String?,
      campus: json['campus'] as String?,
      bio: json['bio'] as String?,
      interests:
          (json['interests'] as List<dynamic>).map((e) => e as String).toList(),
      photoUrls:
          (json['photoUrls'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool,
      isProfileComplete: json['isProfileComplete'] as bool,
      token: json['token'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'age': instance.age,
      'career': instance.career,
      'semester': instance.semester,
      'campus': instance.campus,
      'bio': instance.bio,
      'interests': instance.interests,
      'photoUrls': instance.photoUrls,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isActive': instance.isActive,
      'isProfileComplete': instance.isProfileComplete,
      'token': instance.token,
    };
