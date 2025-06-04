import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';
import '../repositories/discovery_repository.dart';

class GetProfileDetails implements UseCase<Profile, GetProfileDetailsParams> {
  final DiscoveryRepository repository;

  GetProfileDetails(this.repository);

  @override
  Future<Either<Failure, Profile>> call(GetProfileDetailsParams params) async {
    return await repository.getProfileDetails(profileId: params.profileId);
  }
}

class GetProfileDetailsParams extends Equatable {
  final String profileId;

  const GetProfileDetailsParams({required this.profileId});

  @override
  List<Object> get props => [profileId];
}