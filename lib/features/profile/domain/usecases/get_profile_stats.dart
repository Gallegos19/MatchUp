import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileStats implements UseCaseNoParams<ProfileStats> {
  final ProfileRepository repository;

  GetProfileStats(this.repository);

  @override
  Future<Either<Failure, ProfileStats>> call() async {
    return await repository.getStats();
  }
}
