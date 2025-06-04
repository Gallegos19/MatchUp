import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasource/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    if (await networkInfo.isConnected) {
      try {
        final conversationModels = await remoteDataSource.getConversations();
        final conversations = conversationModels.map((model) => model.toEntity()).toList();
        return Right(conversations);
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
  Future<Either<Failure, List<Message>>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final messageModels = await remoteDataSource.getMessages(
          conversationId: conversationId,
          page: page,
          limit: limit,
        );
        final messages = messageModels.map((model) => model.toEntity()).toList();
        return Right(messages);
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
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
    required MessageType type,
    Map<String, dynamic>? metadata,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final messageModel = await remoteDataSource.sendMessage(
          conversationId: conversationId,
          content: content,
          type: type,
          metadata: metadata,
        );
        return Right(messageModel.toEntity());
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
  Future<Either<Failure, void>> markMessagesAsRead({
    required String conversationId,
    required List<String> messageIds,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markMessagesAsRead(
          conversationId: conversationId,
          messageIds: messageIds,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllMessagesAsRead({
    required String conversationId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markAllMessagesAsRead(conversationId: conversationId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    if (await networkInfo.isConnected) {
      try {
        final count = await remoteDataSource.getUnreadCount();
        return Right(count);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }

  @override
  Future<Either<Failure, void>> sendStudyInvitation({
    required String conversationId,
    required String subject,
    required String description,
    required DateTime scheduledTime,
    required String location,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendStudyInvitation(
          conversationId: conversationId,
          subject: subject,
          description: description,
          scheduledTime: scheduledTime,
          location: location,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.statusCode));
      } catch (e) {
        return Left(UnknownFailure(message: 'Error inesperado: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No hay conexión a internet'));
    }
  }
}
