import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/study_group.dart';
import '../repositories/study_groups_repository.dart';

class CreateStudyGroup implements UseCase<StudyGroup, CreateStudyGroupParams> {
  final StudyGroupsRepository repository;

  CreateStudyGroup(this.repository);

  @override
  Future<Either<Failure, StudyGroup>> call(CreateStudyGroupParams params) async {
    return await repository.createStudyGroup(
      name: params.name,
      description: params.description,
      subject: params.subject,
      career: params.career,
      semester: params.semester,
      campus: params.campus,
      maxMembers: params.maxMembers,
      studySchedule: params.studySchedule,
      isPrivate: params.isPrivate,
      requirements: params.requirements,
    );
  }
}

class CreateStudyGroupParams extends Equatable {
  final String name;
  final String description;
  final String subject;
  final String career;
  final int semester;
  final String campus;
  final int maxMembers;
  final Map<String, StudySchedule> studySchedule;
  final bool isPrivate;
  final List<GroupRequirement> requirements;

  const CreateStudyGroupParams({
    required this.name,
    required this.description,
    required this.subject,
    required this.career,
    required this.semester,
    required this.campus,
    required this.maxMembers,
    required this.studySchedule,
    required this.isPrivate,
    required this.requirements,
  });

  @override
  List<Object> get props => [
        name,
        description,
        subject,
        career,
        semester,
        campus,
        maxMembers,
        studySchedule,
        isPrivate,
        requirements,
      ];
}
