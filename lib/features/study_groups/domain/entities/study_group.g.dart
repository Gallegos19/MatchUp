// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudySchedule _$StudyScheduleFromJson(Map<String, dynamic> json) =>
    StudySchedule(
      start: json['start'] as String,
      end: json['end'] as String,
    );

Map<String, dynamic> _$StudyScheduleToJson(StudySchedule instance) =>
    <String, dynamic>{
      'start': instance.start,
      'end': instance.end,
    };

GroupRequirement _$GroupRequirementFromJson(Map<String, dynamic> json) =>
    GroupRequirement(
      type: json['type'] as String,
      value: json['value'],
    );

Map<String, dynamic> _$GroupRequirementToJson(GroupRequirement instance) =>
    <String, dynamic>{
      'type': instance.type,
      'value': instance.value,
    };
