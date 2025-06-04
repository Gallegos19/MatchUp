import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/discovery_repository.dart';

class UpdateFilters implements UseCase<void, UpdateFiltersParams> {
  final DiscoveryRepository repository;

  UpdateFilters(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateFiltersParams params) async {
    return await repository.updateFilters(filters: params.filters);
  }
}

class UpdateFiltersParams extends Equatable {
  final DiscoveryFilters filters;

  const UpdateFiltersParams({required this.filters});

  @override
  List<Object> get props => [filters];
}