import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

enum EventType { social, academic, sports, cultural, networking }

class Event extends Equatable {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final String location;
  final String campus;
  final DateTime startDate;
  final DateTime endDate;
  final int maxParticipants;
  final int currentParticipants;
  final bool isPublic;
  final String authorId;
  final String authorName;
  final List<String> tags;
  final List<EventRequirement> requirements;
  final bool isJoined;
  final DateTime createdAt;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.location,
    required this.campus,
    required this.startDate,
    required this.endDate,
    required this.maxParticipants,
    this.currentParticipants = 0,
    this.isPublic = true,
    required this.authorId,
    required this.authorName,
    this.tags = const [],
    this.requirements = const [],
    this.isJoined = false,
    required this.createdAt,
  });

  bool get isFull => currentParticipants >= maxParticipants;
  bool get hasStarted => DateTime.now().isAfter(startDate);
  bool get hasEnded => DateTime.now().isAfter(endDate);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        location,
        campus,
        startDate,
        endDate,
        maxParticipants,
        currentParticipants,
        isPublic,
        authorId,
        authorName,
        tags,
        requirements,
        isJoined,
        createdAt,
      ];
}

@JsonSerializable()
class EventRequirement extends Equatable {
  final String type;
  final dynamic value;

  const EventRequirement({
    required this.type,
    required this.value,
  });

  factory EventRequirement.fromJson(Map<String, dynamic> json) => _$EventRequirementFromJson(json);
  Map<String, dynamic> toJson() => _$EventRequirementToJson(this);

  @override
  List<Object?> get props => [type, value];
}