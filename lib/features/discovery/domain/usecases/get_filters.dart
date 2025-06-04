import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/discovery_repository.dart';

class GetFilters implements UseCaseNoParams<DiscoveryFilters> {
  final DiscoveryRepository repository;

  GetFilters(this.repository);

  @override
  Future<Either<Failure, DiscoveryFilters>> call() async {
    return await repository.getFilters();
  }
}