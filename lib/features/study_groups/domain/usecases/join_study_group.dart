import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/study_groups_repository.dart';

class JoinStudyGroup implements UseCase<void, JoinStudyGroupParams> {
  final StudyGroupsRepository repository;

  JoinStudyGroup(this.repository);

  @override
  Future<Either<Failure, void>> call(JoinStudyGroupParams params) async {
    return await repository.joinStudyGroup(params.groupId);
  }
}

class JoinStudyGroupParams extends Equatable {
  final String groupId;

  const JoinStudyGroupParams({required this.groupId});

  @override
  List<Object> get props => [groupId];
}