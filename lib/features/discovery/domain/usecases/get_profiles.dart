import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';
import '../repositories/discovery_repository.dart';

class GetProfiles implements UseCase<List<Profile>, GetProfilesParams> {
  final DiscoveryRepository repository;

  GetProfiles(this.repository);

  @override
  Future<Either<Failure, List<Profile>>> call(GetProfilesParams params) async {
    return await repository.getProfiles(
      filters: params.filters,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetProfilesParams extends Equatable {
  final DiscoveryFilters? filters;
  final int page;
  final int limit;

  const GetProfilesParams({
    this.filters,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [filters, page, limit];
}