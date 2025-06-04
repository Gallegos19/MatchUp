// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventRequirement _$EventRequirementFromJson(Map<String, dynamic> json) =>
    EventRequirement(
      type: json['type'] as String,
      value: json['value'],
    );

Map<String, dynamic> _$EventRequirementToJson(EventRequirement instance) =>
    <String, dynamic>{
      'type': instance.type,
      'value': instance.value,
    };
