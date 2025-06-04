import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileSettings implements UseCase<ProfileSettings, UpdateProfileSettingsParams> {
  final ProfileRepository repository;

  UpdateProfileSettings(this.repository);

  @override
  Future<Either<Failure, ProfileSettings>> call(UpdateProfileSettingsParams params) async {
    return await repository.updateSettings(params.settings);
  }
}

class UpdateProfileSettingsParams extends Equatable {
  final ProfileSettings settings;

  const UpdateProfileSettingsParams({required this.settings});

  @override
  List<Object> get props => [settings];
}

