import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/study_group.dart';
import '../repositories/study_groups_repository.dart';

class GetStudyGroups implements UseCase<List<StudyGroup>, GetStudyGroupsParams> {
  final StudyGroupsRepository repository;

  GetStudyGroups(this.repository);

  @override
  Future<Either<Failure, List<StudyGroup>>> call(GetStudyGroupsParams params) async {
    return await repository.getStudyGroups(
      page: params.page,
      limit: params.limit,
      campus: params.campus,
      subject: params.subject,
      career: params.career,
    );
  }
}

class GetStudyGroupsParams extends Equatable {
  final int page;
  final int limit;
  final String? campus;
  final String? subject;
  final String? career;

  const GetStudyGroupsParams({
    this.page = 1,
    this.limit = 20,
    this.campus,
    this.subject,
    this.career,
  });

  @override
  List<Object?> get props => [page, limit, campus, subject, career];
}