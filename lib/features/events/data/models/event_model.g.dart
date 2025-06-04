// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventModel _$EventModelFromJson(Map<String, dynamic> json) => EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$EventTypeEnumMap, json['type']),
      location: json['location'] as String,
      campus: json['campus'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      maxParticipants: (json['maxParticipants'] as num).toInt(),
      currentParticipants: (json['currentParticipants'] as num?)?.toInt() ?? 0,
      isPublic: json['isPublic'] as bool? ?? true,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      requirements: (json['requirements'] as List<dynamic>?)
              ?.map((e) => EventRequirement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isJoined: json['isJoined'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$EventModelToJson(EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$EventTypeEnumMap[instance.type]!,
      'location': instance.location,
      'campus': instance.campus,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'maxParticipants': instance.maxParticipants,
      'currentParticipants': instance.currentParticipants,
      'isPublic': instance.isPublic,
      'authorId': instance.authorId,
      'authorName': instance.authorName,
      'tags': instance.tags,
      'requirements': instance.requirements,
      'isJoined': instance.isJoined,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$EventTypeEnumMap = {
  EventType.social: 'social',
  EventType.academic: 'academic',
  EventType.sports: 'sports',
  EventType.cultural: 'cultural',
  EventType.networking: 'networking',
};
