import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SendMessage implements UseCase<Message, SendMessageParams> {
  final ChatRepository repository;

  SendMessage(this.repository);

  @override
  Future<Either<Failure, Message>> call(SendMessageParams params) async {
    return await repository.sendMessage(
      conversationId: params.conversationId,
      content: params.content,
      type: params.type,
      metadata: params.metadata,
    );
  }
}

class SendMessageParams extends Equatable {
  final String conversationId;
  final String content;
  final MessageType type;
  final Map<String, dynamic>? metadata;

  const SendMessageParams({
    required this.conversationId,
    required this.content,
    required this.type,
    this.metadata,
  });

  @override
  List<Object?> get props => [conversationId, content, type, metadata];
}
