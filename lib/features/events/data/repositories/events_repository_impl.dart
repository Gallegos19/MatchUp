// lib/features/events/data/repositories/events_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';
import '../datasource/events_remote_datasource.dart';

class EventsRepositoryImpl implements EventsRepository {
  final EventsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  EventsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Event>>> getEvents({
    int page = 1,
    int limit = 20,
    String? campus,
    EventType? type,
    List<String>? tags,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final eventModels = await remoteDataSource.getEvents(
          page: page,
          limit: limit,
          campus: campus,
          type: type,
          tags: tags,
        );
        final events = eventModels.map((model) => model.toEntity()).toList();
        return Right(events);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
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
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final eventModel = await remoteDataSource.createEvent(
          title: title,
          description: description,
          type: type,
          location: location,
          campus: campus,
          startDate: startDate,
          endDate: endDate,
          maxParticipants: maxParticipants,
          isPublic: isPublic,
          tags: tags,
          requirements: requirements,
        );
        return Right(eventModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getMyEvents() async {
    if (await networkInfo.isConnected) {
      try {
        final eventModels = await remoteDataSource.getMyEvents();
        final events = eventModels.map((model) => model.toEntity()).toList();
        return Right(events);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, Event>> getEventById(String eventId) async {
    if (await networkInfo.isConnected) {
      try {
        final eventModel = await remoteDataSource.getEventById(eventId);
        return Right(eventModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, Event>> updateEvent({
    required String eventId,
    String? title,
    String? description,
    String? location,
    int? maxParticipants,
    List<String>? tags,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final eventModel = await remoteDataSource.updateEvent(
          eventId: eventId,
          title: title,
          description: description,
          location: location,
          maxParticipants: maxParticipants,
          tags: tags,
        );
        return Right(eventModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelEvent({
    required String eventId,
    required String reason,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.cancelEvent(eventId: eventId, reason: reason);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> joinEvent(String eventId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.joinEvent(eventId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> leaveEvent(String eventId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.leaveEvent(eventId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }
}