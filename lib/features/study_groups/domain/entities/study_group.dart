import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'study_group.g.dart';

class StudyGroup extends Equatable {
  final String id;
  final String name;
  final String description;
  final String subject;
  final String career;
  final int semester;
  final String campus;
  final int maxMembers;
  final int currentMembers;
  final Map<String, StudySchedule> studySchedule;
  final bool isPrivate;
  final String authorId;
  final String authorName;
  final List<GroupRequirement> requirements;
  final bool isJoined;
  final DateTime createdAt;

  const StudyGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.subject,
    required this.career,
    required this.semester,
    required this.campus,
    required this.maxMembers,
    this.currentMembers = 0,
    this.studySchedule = const {},
    this.isPrivate = false,
    required this.authorId,
    required this.authorName,
    this.requirements = const [],
    this.isJoined = false,
    required this.createdAt,
  });

  bool get isFull => currentMembers >= maxMembers;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        subject,
        career,
        semester,
        campus,
        maxMembers,
        currentMembers,
        studySchedule,
        isPrivate,
        authorId,
        authorName,
        requirements,
        isJoined,
        createdAt,
      ];
}

@JsonSerializable()
class StudySchedule extends Equatable {
  final String start;
  final String end;

  const StudySchedule({
    required this.start,
    required this.end,
  });

  factory StudySchedule.fromJson(Map<String, dynamic> json) => _$StudyScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$StudyScheduleToJson(this);

  @override
  List<Object> get props => [start, end];
}

@JsonSerializable()
class GroupRequirement extends Equatable {
  final String type;
  final dynamic value;

  const GroupRequirement({
    required this.type,
    required this.value,
  });

  factory GroupRequirement.fromJson(Map<String, dynamic> json) => _$GroupRequirementFromJson(json);
  Map<String, dynamic> toJson() => _$GroupRequirementToJson(this);

  @override
  List<Object?> get props => [type, value];
}

class GroupMember extends Equatable {
  final String id;
  final String name;
  final String career;
  final int semester;
  final String? profilePicture;
  final bool isAdmin;
  final DateTime joinedAt;

  const GroupMember({
    required this.id,
    required this.name,
    required this.career,
    required this.semester,
    this.profilePicture,
    this.isAdmin = false,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        career,
        semester,
        profilePicture,
        isAdmin,
        joinedAt,
      ];
}