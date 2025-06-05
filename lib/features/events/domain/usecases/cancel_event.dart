import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/events_repository.dart';

class CancelEvent implements UseCase<void, CancelEventParams> {
  final EventsRepository repository;

  CancelEvent(this.repository);

  @override
  Future<Either<Failure, void>> call(CancelEventParams params) async {
    return await repository.cancelEvent(
      eventId: params.eventId,
      reason: params.reason,
    );
  }
}

class CancelEventParams extends Equatable {
  final String eventId;
  final String reason;

  const CancelEventParams({
    required this.eventId,
    required this.reason,
  });

  @override
  List<Object> get props => [eventId, reason];
}
