import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/event.dart';
import '../repositories/events_repository.dart';

class UpdateEvent implements UseCase<Event, UpdateEventParams> {
  final EventsRepository repository;

  UpdateEvent(this.repository);

  @override
  Future<Either<Failure, Event>> call(UpdateEventParams params) async {
    return await repository.updateEvent(
      eventId: params.eventId,
      title: params.title,
      description: params.description,
      location: params.location,
      maxParticipants: params.maxParticipants,
      tags: params.tags,
    );
  }
}

class UpdateEventParams extends Equatable {
  final String eventId;
  final String? title;
  final String? description;
  final String? location;
  final int? maxParticipants;
  final List<String>? tags;

  const UpdateEventParams({
    required this.eventId,
    this.title,
    this.description,
    this.location,
    this.maxParticipants,
    this.tags,
  });

  @override
  List<Object?> get props => [
    eventId,
    title,
    description,
    location,
    maxParticipants,
    tags,
  ];
}
