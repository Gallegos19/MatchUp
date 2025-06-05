import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/event.dart';
import '../repositories/events_repository.dart';

class GetEventById implements UseCase<Event, GetEventByIdParams> {
  final EventsRepository repository;

  GetEventById(this.repository);

  @override
  Future<Either<Failure, Event>> call(GetEventByIdParams params) async {
    return await repository.getEventById(params.eventId);
  }
}

class GetEventByIdParams extends Equatable {
  final String eventId;

  const GetEventByIdParams({required this.eventId});

  @override
  List<Object> get props => [eventId];
}
