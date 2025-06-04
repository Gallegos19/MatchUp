
// lib/features/chat/domain/repositories/chat_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<Conversation>>> getConversations();
  
  Future<Either<Failure, List<Message>>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 20,
  });
  
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
    required MessageType type,
    Map<String, dynamic>? metadata,
  });
  
  Future<Either<Failure, void>> markMessagesAsRead({
    required String conversationId,
    required List<String> messageIds,
  });
  
  Future<Either<Failure, void>> markAllMessagesAsRead({
    required String conversationId,
  });
  
  Future<Either<Failure, int>> getUnreadCount();
  
  Future<Either<Failure, void>> sendStudyInvitation({
    required String conversationId,
    required String subject,
    required String description,
    required DateTime scheduledTime,
    required String location,
  });
}
