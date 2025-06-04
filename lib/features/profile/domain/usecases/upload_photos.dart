import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UploadPhotos implements UseCase<List<String>, UploadPhotosParams> {
  final ProfileRepository repository;

  UploadPhotos(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(UploadPhotosParams params) async {
    return await repository.uploadPhotos(params.imagePaths);
  }
}

class UploadPhotosParams extends Equatable {
  final List<String> imagePaths;

  const UploadPhotosParams({required this.imagePaths});

  @override
  List<Object> get props => [imagePaths];
}