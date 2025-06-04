import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/study_group.dart';
import '../../domain/repositories/study_groups_repository.dart';
import '../datasource/study_groups_remote_datasource.dart';

class StudyGroupsRepositoryImpl implements StudyGroupsRepository {
  final StudyGroupsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  StudyGroupsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<StudyGroup>>> getStudyGroups({
    int page = 1,
    int limit = 20,
    String? campus,
    String? subject,
    String? career,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final groupModels = await remoteDataSource.getStudyGroups(
          page: page,
          limit: limit,
          campus: campus,
          subject: subject,
          career: career,
        );
        final groups = groupModels.map((model) => model.toEntity()).toList();
        return Right(groups);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
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
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final groupModel = await remoteDataSource.createStudyGroup(
          name: name,
          description: description,
          subject: subject,
          career: career,
          semester: semester,
          campus: campus,
          maxMembers: maxMembers,
          studySchedule: studySchedule,
          isPrivate: isPrivate,
          requirements: requirements,
        );
        return Right(groupModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, List<StudyGroup>>> searchStudyGroups({
    required String query,
    String? campus,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final groupModels = await remoteDataSource.searchStudyGroups(
          query: query,
          campus: campus,
          limit: limit,
        );
        final groups = groupModels.map((model) => model.toEntity()).toList();
        return Right(groups);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getPopularSubjects({
    String? campus,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final subjects = await remoteDataSource.getPopularSubjects(
          campus: campus,
          limit: limit,
        );
        return Right(subjects);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, List<StudyGroup>>> getMyGroups() async {
    if (await networkInfo.isConnected) {
      try {
        final groupModels = await remoteDataSource.getMyGroups();
        final groups = groupModels.map((model) => model.toEntity()).toList();
        return Right(groups);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, StudyGroup>> getStudyGroupById(String groupId) async {
    if (await networkInfo.isConnected) {
      try {
        final groupModel = await remoteDataSource.getStudyGroupById(groupId);
        return Right(groupModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, List<GroupMember>>> getGroupMembers(String groupId) async {
    if (await networkInfo.isConnected) {
      try {
        final memberModels = await remoteDataSource.getGroupMembers(groupId);
        final members = memberModels.map((model) => model.toEntity()).toList();
        return Right(members);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, StudyGroup>> updateStudyGroup({
    required String groupId,
    String? name,
    String? description,
    Map<String, StudySchedule>? studySchedule,
    int? maxMembers,
    bool? isPrivate,
    List<GroupRequirement>? requirements,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final groupModel = await remoteDataSource.updateStudyGroup(
          groupId: groupId,
          name: name,
          description: description,
          studySchedule: studySchedule,
          maxMembers: maxMembers,
          isPrivate: isPrivate,
          requirements: requirements,
        );
        return Right(groupModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStudyGroup({
    required String groupId,
    required String reason,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteStudyGroup(groupId: groupId, reason: reason);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> joinStudyGroup(String groupId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.joinStudyGroup(groupId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> leaveStudyGroup(String groupId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.leaveStudyGroup(groupId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }
}