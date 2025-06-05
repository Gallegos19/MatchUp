// lib/features/profile/domain/usecases/update_profile.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile implements UseCase<UserProfile, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      firstName: params.firstName,
      lastName: params.lastName,
      bio: params.bio,
      career: params.career,
      semester: params.semester,
      campus: params.campus,
      interests: params.interests,
      photoUrls: params.photoUrls,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? bio;
  final String? career;
  final String? semester;
  final String? campus;
  final List<String>? interests;
  final List<String>? photoUrls;

  const UpdateProfileParams({
    this.firstName,
    this.lastName,
    this.bio,
    this.career,
    this.semester,
    this.campus,
    this.interests,
    this.photoUrls,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        bio,
        career,
        semester,
        campus,
        interests,
        photoUrls,
      ];
}