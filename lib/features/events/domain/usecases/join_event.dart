import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/events_repository.dart';

class JoinEvent implements UseCase<void, JoinEventParams> {
  final EventsRepository repository;

  JoinEvent(this.repository);

  @override
  Future<Either<Failure, void>> call(JoinEventParams params) async {
    return await repository.joinEvent(params.eventId);
  }
}

class JoinEventParams extends Equatable {
  final String eventId;

  const JoinEventParams({required this.eventId});

  @override
  List<Object> get props => [eventId];
}