
// lib/features/study_groups/domain/repositories/study_groups_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/study_group.dart';

abstract class StudyGroupsRepository {
  Future<Either<Failure, List<StudyGroup>>> getStudyGroups({
    int page = 1,
    int limit = 20,
    String? campus,
    String? subject,
    String? career,
  });

  Future<Either<Failure, StudyGroup>> createStudyGroup({
    required String name,
    required String description,
    required String subject,
    required String career,
    required int semester,
    required String campus,
    required int maxMembers,
    required Map<String, StudySchedule> studySchedule,
    required bool isPrivate,
    required List<GroupRequirement> requirements,
  });

  Future<Either<Failure, List<StudyGroup>>> searchStudyGroups({
    required String query,
    String? campus,
    int limit = 20,
  });

  Future<Either<Failure, List<String>>> getPopularSubjects({
    String? campus,
    int limit = 20,
  });

  Future<Either<Failure, List<StudyGroup>>> getMyGroups();

  Future<Either<Failure, StudyGroup>> getStudyGroupById(String groupId);

  Future<Either<Failure, List<GroupMember>>> getGroupMembers(String groupId);

  Future<Either<Failure, StudyGroup>> updateStudyGroup({
    required String groupId,
    String? name,
    String? description,
    Map<String, StudySchedule>? studySchedule,
    int? maxMembers,
    bool? isPrivate,
    List<GroupRequirement>? requirements,
  });

  Future<Either<Failure, void>> deleteStudyGroup({
    required String groupId,
    required String reason,
  });

  Future<Either<Failure, void>> joinStudyGroup(String groupId);

  Future<Either<Failure, void>> leaveStudyGroup(String groupId);
}
