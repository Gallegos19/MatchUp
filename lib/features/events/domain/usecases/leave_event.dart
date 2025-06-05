import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/events_repository.dart';

class LeaveEvent implements UseCase<void, LeaveEventParams> {
  final EventsRepository repository;

  LeaveEvent(this.repository);

  @override
  Future<Either<Failure, void>> call(LeaveEventParams params) async {
    return await repository.leaveEvent(params.eventId);
  }
}

class LeaveEventParams extends Equatable {
  final String eventId;

  const LeaveEventParams({required this.eventId});

  @override
  List<Object> get props => [eventId];
}