
// lib/features/events/domain/repositories/events_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/event.dart';

abstract class EventsRepository {
  Future<Either<Failure, List<Event>>> getEvents({
    int page = 1,
    int limit = 20,
    String? campus,
    EventType? type,
    List<String>? tags,
  });

  Future<Either<Failure, Event>> createEvent({
    required String title,
    required String description,
    required EventType type,
    required String location,
    required String campus,
    required DateTime startDate,
    required DateTime endDate,
    required int maxParticipants,
    required bool isPublic,
    required List<String> tags,
    required List<EventRequirement> requirements,
  });

  Future<Either<Failure, List<Event>>> getMyEvents();

  Future<Either<Failure, Event>> getEventById(String eventId);

  Future<Either<Failure, Event>> updateEvent({
    required String eventId,
    String? title,
    String? description,
    String? location,
    int? maxParticipants,
    List<String>? tags,
  });

  Future<Either<Failure, void>> cancelEvent({
    required String eventId,
    required String reason,
  });

  Future<Either<Failure, void>> joinEvent(String eventId);

  Future<Either<Failure, void>> leaveEvent(String eventId);
}
