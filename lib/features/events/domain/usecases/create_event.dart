import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/event.dart';
import '../repositories/events_repository.dart';

class CreateEvent implements UseCase<Event, CreateEventParams> {
  final EventsRepository repository;

  CreateEvent(this.repository);

  @override
  Future<Either<Failure, Event>> call(CreateEventParams params) async {
    return await repository.createEvent(
      title: params.title,
      description: params.description,
      type: params.type,
      location: params.location,
      campus: params.campus,
      startDate: params.startDate,
      endDate: params.endDate,
      maxParticipants: params.maxParticipants,
      isPublic: params.isPublic,
      tags: params.tags,
      requirements: params.requirements,
    );
  }
}

class CreateEventParams extends Equatable {
  final String title;
  final String description;
  final EventType type;
  final String location;
  final String campus;
  final DateTime startDate;
  final DateTime endDate;
  final int maxParticipants;
  final bool isPublic;
  final List<String> tags;
  final List<EventRequirement> requirements;

  const CreateEventParams({
    required this.title,
    required this.description,
    required this.type,
    required this.location,
    required this.campus,
    required this.startDate,
    required this.endDate,
    required this.maxParticipants,
    required this.isPublic,
    required this.tags,
    required this.requirements,
  });

  @override
  List<Object> get props => [
        title,
        description,
        type,
        location,
        campus,
        startDate,
        endDate,
        maxParticipants,
        isPublic,
        tags,
        requirements,
      ];
}