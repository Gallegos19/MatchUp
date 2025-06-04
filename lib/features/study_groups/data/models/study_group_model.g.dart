// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudyGroupModel _$StudyGroupModelFromJson(Map<String, dynamic> json) =>
    StudyGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      subject: json['subject'] as String,
      career: json['career'] as String,
      semester: (json['semester'] as num).toInt(),
      campus: json['campus'] as String,
      maxMembers: (json['maxMembers'] as num).toInt(),
      currentMembers: (json['currentMembers'] as num?)?.toInt() ?? 0,
      studySchedule: (json['studySchedule'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, StudySchedule.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      isPrivate: json['isPrivate'] as bool? ?? false,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      requirements: (json['requirements'] as List<dynamic>?)
              ?.map((e) => GroupRequirement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isJoined: json['isJoined'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$StudyGroupModelToJson(StudyGroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'subject': instance.subject,
      'career': instance.career,
      'semester': instance.semester,
      'campus': instance.campus,
      'maxMembers': instance.maxMembers,
      'currentMembers': instance.currentMembers,
      'studySchedule': instance.studySchedule,
      'isPrivate': instance.isPrivate,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'requirements': instance.requirements,
      'isJoined': instance.isJoined,
      'createdAt': instance.createdAt.toIso8601String(),
    };

GroupMemberModel _$GroupMemberModelFromJson(Map<String, dynamic> json) =>
    GroupMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      career: json['career'] as String,
      semester: (json['semester'] as num).toInt(),
      profilePicture: json['profilePicture'] as String?,
      isAdmin: json['isAdmin'] as bool? ?? false,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$GroupMemberModelToJson(GroupMemberModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'career': instance.career,
      'semester': instance.semester,
      'profilePicture': instance.profilePicture,
      'isAdmin': instance.isAdmin,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };
