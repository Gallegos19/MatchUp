import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/event.dart';
import '../repositories/events_repository.dart';

class GetEvents implements UseCase<List<Event>, GetEventsParams> {
  final EventsRepository repository;

  GetEvents(this.repository);

  @override
  Future<Either<Failure, List<Event>>> call(GetEventsParams params) async {
    return await repository.getEvents(
      page: params.page,
      limit: params.limit,
      campus: params.campus,
      type: params.type,
      tags: params.tags,
    );
  }
}

class GetEventsParams extends Equatable {
  final int page;
  final int limit;
  final String? campus;
  final EventType? type;
  final List<String>? tags;

  const GetEventsParams({
    this.page = 1,
    this.limit = 20,
    this.campus,
    this.type,
    this.tags,
  });

  @override
  List<Object?> get props => [page, limit, campus, type, tags];
}