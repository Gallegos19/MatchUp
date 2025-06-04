import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile implements UseCaseNoParams<UserProfile> {
  final ProfileRepository repository;

  GetProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call() async {
    return await repository.getProfile();
  }
}
