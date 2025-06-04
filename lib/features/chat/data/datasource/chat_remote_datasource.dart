
// lib/features/chat/data/datasource/chat_remote_datasource.dart
import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../../domain/entities/message.dart';

abstract class ChatRemoteDataSource {
  Future<List<ConversationModel>> getConversations();
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 20,
  });
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    required MessageType type,
    Map<String, dynamic>? metadata,
  });
  Future<void> markMessagesAsRead({
    required String conversationId,
    required List<String> messageIds,
  });
  Future<void> markAllMessagesAsRead({
    required String conversationId,
  });
  Future<int> getUnreadCount();
  Future<void> sendStudyInvitation({
    required String conversationId,
    required String subject,
    required String description,
    required DateTime scheduledTime,
    required String location,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await dio.get('chat/conversations');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> conversationsJson = data is List ? data : data['conversations'] ?? [];
        
        return conversationsJson
            .map((json) => ConversationModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al obtener conversaciones',
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
  Future<List<MessageModel>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await dio.get(
        'chat/$conversationId/messages',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final List<dynamic> messagesJson = data is List ? data : data['messages'] ?? [];
        
        return messagesJson
            .map((json) => MessageModel.fromJson(json))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al obtener mensajes',
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
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
    required MessageType type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      String typeString;
      switch (type) {
        case MessageType.text:
          typeString = 'text';
          break;
        case MessageType.image:
          typeString = 'image';
          break;
        case MessageType.studyInvitation:
          typeString = 'study_invitation';
          break;
      }

      final response = await dio.post(
        'chat/$conversationId/messages',
        data: {
          'content': content,
          'messageType': typeString,
          'metadata': metadata ?? {},
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        return MessageModel.fromJson(data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al enviar mensaje',
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
  Future<void> markMessagesAsRead({
    required String conversationId,
    required List<String> messageIds,
  }) async {
    try {
      final response = await dio.patch(
        'chat/$conversationId/messages/read',
        data: {
          'messageIds': messageIds,
        },
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al marcar mensajes como leídos',
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
  Future<void> markAllMessagesAsRead({
    required String conversationId,
  }) async {
    try {
      final response = await dio.patch('chat/$conversationId/messages/read-all');

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al marcar todos los mensajes como leídos',
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
  Future<int> getUnreadCount() async {
    try {
      final response = await dio.get('chat/unread-count');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        return data['unreadCount'] ?? 0;
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Error al obtener contador no leídos',
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
  Future<void> sendStudyInvitation({
    required String conversationId,
    required String subject,
    required String description,
    required DateTime scheduledTime,
    required String location,
  }) async {
    try {
      final response = await dio.post(
        'chat/$conversationId/study-invitation',
        data: {
          'subject': subject,
          'description': description,
          'scheduledTime': scheduledTime.toIso8601String(),
          'location': location,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: response.data['message'] ?? 'Error al enviar invitación de estudio',
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