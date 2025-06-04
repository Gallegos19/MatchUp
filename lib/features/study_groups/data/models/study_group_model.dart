// lib/features/study_groups/data/models/study_group_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/study_group.dart';

part 'study_group_model.g.dart';

@JsonSerializable()
class StudyGroupModel extends StudyGroup {
  const StudyGroupModel({
    required super.id,
    required super.name,
    required super.description,
    required super.subject,
    required super.career,
    required super.semester,
    required super.campus,
    required super.maxMembers,
    super.currentMembers = 0,
    super.studySchedule = const {},
    super.isPrivate = false,
    required super.authorId,
    required super.authorName,
    super.requirements = const [],
    super.isJoined = false,
    required super.createdAt,
  });

  factory StudyGroupModel.fromJson(Map<String, dynamic> json) {
    return StudyGroupModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      subject: json['subject'] ?? '',
      career: json['career'] ?? '',
      semester: json['semester'] ?? 1,
      campus: json['campus'] ?? '',
      maxMembers: json['maxMembers'] ?? 0,
      currentMembers: json['currentMembers'] ?? json['memberCount'] ?? 0,
      studySchedule: _parseStudySchedule(json['studySchedule']),
      isPrivate: json['isPrivate'] ?? false,
      authorId: json['authorId'] ?? json['author']?['id'] ?? '',
      authorName: _buildAuthorName(json['author']),
      requirements: _parseRequirements(json['requirements']),
      isJoined: json['isJoined'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static Map<String, StudySchedule> _parseStudySchedule(dynamic schedule) {
    if (schedule == null) return {};
    
    if (schedule is Map<String, dynamic>) {
      return schedule.map((key, value) {
        if (value is Map<String, dynamic>) {
          return MapEntry(
            key,
            StudySchedule(
              start: value['start'] ?? '',
              end: value['end'] ?? '',
            ),
          );
        }
        return MapEntry(key, const StudySchedule(start: '', end: ''));
      });
    }
    
    return {};
  }

  static String _buildAuthorName(Map<String, dynamic>? author) {
    if (author == null) return 'Administrador';
    
    final firstName = author['firstName'] ?? '';
    final lastName = author['lastName'] ?? '';
    final fullName = author['name'];
    
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }
    
    return '$firstName $lastName'.trim();
  }

  static List<GroupRequirement> _parseRequirements(dynamic requirements) {
    if (requirements == null) return [];
    
    if (requirements is List) {
      return requirements.map((req) {
        if (req is Map<String, dynamic>) {
          return GroupRequirement(
            type: req['type'] ?? '',
            value: req['value'] ?? req['minSemester'] ?? req['minGpa'],
          );
        }
        return const GroupRequirement(type: '', value: null);
      }).toList();
    }
    
    return [];
  }

  Map<String, dynamic> toJson() => _$StudyGroupModelToJson(this);

  StudyGroup toEntity() {
    return StudyGroup(
      id: id,
      name: name,
      description: description,
      subject: subject,
      career: career,
      semester: semester,
      campus: campus,
      maxMembers: maxMembers,
      currentMembers: currentMembers,
      studySchedule: studySchedule,
      isPrivate: isPrivate,
      authorId: authorId,
      authorName: authorName,
      requirements: requirements,
      isJoined: isJoined,
      createdAt: createdAt,
    );
  }
}

@JsonSerializable()
class GroupMemberModel extends GroupMember {
  const GroupMemberModel({
    required super.id,
    required super.name,
    required super.career,
    required super.semester,
    super.profilePicture,
    super.isAdmin = false,
    required super.joinedAt,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      id: json['id'] ?? '',
      name: _buildMemberName(json),
      career: json['career'] ?? json['academicProfile']?['career'] ?? '',
      semester: json['semester'] ?? json['academicProfile']?['semester'] ?? 1,
      profilePicture: json['profilePicture'],
      isAdmin: json['isAdmin'] ?? false,
      joinedAt: DateTime.parse(json['joinedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static String _buildMemberName(Map<String, dynamic> json) {
    final firstName = json['firstName'] ?? '';
    final lastName = json['lastName'] ?? '';
    final fullName = json['name'];
    
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }
    
    return '$firstName $lastName'.trim();
  }

  Map<String, dynamic> toJson() => _$GroupMemberModelToJson(this);

  GroupMember toEntity() {
    return GroupMember(
      id: id,
      name: name,
      career: career,
      semester: semester,
      profilePicture: profilePicture,
      isAdmin: isAdmin,
      joinedAt: joinedAt,
    );
  }
}