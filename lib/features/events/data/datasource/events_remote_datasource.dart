
// lib/features/events/data/datasource/events_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/event_model.dart';
import '../../domain/entities/event.dart';

abstract class EventsRemoteDataSource {
  Future<List<EventModel>> getEvents({
    int page = 1,
    int limit = 20,
    String? campus,
    EventType? type,
    List<String>? tags,
  });

  Future<EventModel> createEvent({
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

  Future<List<EventModel>> getMyEvents();
  Future<EventModel> getEventById(String eventId);
  Future<EventModel> updateEvent({
    required String eventId,
    String? title,
    String? description,
    String? location,
    int? maxParticipants,
    List<String>? tags,
  });
  Future<void> cancelEvent({
    required String eventId,
    required String reason,
  });
  Future<void> joinEvent(String eventId);
  Future<void> leaveEvent(String eventId);
}

class EventsRemoteDataSourceImpl implements EventsRemoteDataSource {
  final Dio dio;

  EventsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<EventModel>> getEvents({
    int page = 1,
    int limit = 20,
    String? campus,
    EventType? type,
    List<String>? tags,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (campus != null) queryParams['campus'] = campus;
      if (type != null) queryParams['type'] = type.toString().split('.').last;
      if (tags != null) queryParams['tags'] = tags;

      final response = await dio.get('events/', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> eventsJson = data is List ? data : data['events'] ?? [];
        
        return eventsJson.map((json) => EventModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al obtener eventos',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<EventModel> createEvent({
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
    try {
      final response = await dio.post(
        'events/',
        data: {
          'title': title,
          'description': description,
          'eventType': type.toString().split('.').last,
          'location': location,
          'campus': campus,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'maxParticipants': maxParticipants,
          'isPublic': isPublic,
          'tags': tags,
          'requirements': requirements.map((req) => {
            'type': req.type,
            if (req.type == 'semester') 'minSemester': req.value,
            if (req.type == 'gpa') 'minGpa': req.value,
          }).toList(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return EventModel.fromJson(data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al crear evento',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<EventModel>> getMyEvents() async {
    try {
      final response = await dio.get('events/my-events');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> eventsJson = data is List ? data : data['events'] ?? [];
        
        return eventsJson.map((json) => EventModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al obtener mis eventos',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<EventModel> getEventById(String eventId) async {
    try {
      final response = await dio.get('events/$eventId');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return EventModel.fromJson(data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al obtener evento',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<EventModel> updateEvent({
    required String eventId,
    String? title,
    String? description,
    String? location,
    int? maxParticipants,
    List<String>? tags,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (location != null) data['location'] = location;
      if (maxParticipants != null) data['maxParticipants'] = maxParticipants;
      if (tags != null) data['tags'] = tags;

      final response = await dio.put('events/$eventId', data: data);

      if (response.statusCode == 200) {
        final responseData = response.data['data'] ?? response.data;
        return EventModel.fromJson(responseData);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al actualizar evento',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> cancelEvent({
    required String eventId,
    required String reason,
  }) async {
    try {
      final response = await dio.patch(
        'events/$eventId/cancel',
        data: {'reason': reason},
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al cancelar evento',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> joinEvent(String eventId) async {
    try {
      final response = await dio.post('events/$eventId/join');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al unirse al evento',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> leaveEvent(String eventId) async {
    try {
      final response = await dio.delete('events/$eventId/leave');

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al salir del evento',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: $e',
        statusCode: 500,
      );
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Tiempo de espera agotado',
          statusCode: e.response?.statusCode,
        );
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? 'Error del servidor';
        
        switch (statusCode) {
          case 400:
            return ValidationException(message: message, statusCode: statusCode);
          case 401:
            return AuthenticationException(message: message, statusCode: statusCode);
          case 403:
            return UnauthorizedException(message: message, statusCode: statusCode);
          case 404:
            return NotFoundException(message: message, statusCode: statusCode);
          default:
            return ServerException(message: message, statusCode: statusCode);
        }
      
      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Error de conexión. Verifica tu internet',
          statusCode: null,
        );
      
      default:
        return ServerException(
          message: 'Error inesperado: ${e.message}',
          statusCode: e.response?.statusCode,
        );
    }
  }
}