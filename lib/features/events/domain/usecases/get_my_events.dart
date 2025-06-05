import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/event.dart';
import '../repositories/events_repository.dart';

class GetMyEvents implements UseCaseNoParams<List<Event>> {
  final EventsRepository repository;

  GetMyEvents(this.repository);

  @override
  Future<Either<Failure, List<Event>>> call() async {
    return await repository.getMyEvents();
  }
}
