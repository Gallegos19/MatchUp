import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class GetMessages implements UseCase<List<Message>, GetMessagesParams> {
  final ChatRepository repository;

  GetMessages(this.repository);

  @override
  Future<Either<Failure, List<Message>>> call(GetMessagesParams params) async {
    return await repository.getMessages(
      conversationId: params.conversationId,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetMessagesParams extends Equatable {
  final String conversationId;
  final int page;
  final int limit;

  const GetMessagesParams({
    required this.conversationId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object> get props => [conversationId, page, limit];
}