import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/get_conversations.dart';
import '../../domain/usecases/get_messages.dart';
import '../../domain/usecases/send_message.dart';

// States
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ConversationsLoaded extends ChatState {
  final List<Conversation> conversations;

  const ConversationsLoaded({required this.conversations});

  @override
  List<Object> get props => [conversations];
}

class MessagesLoaded extends ChatState {
  final List<Message> messages;
  final String conversationId;

  const MessagesLoaded({
    required this.messages,
    required this.conversationId,
  });

  @override
  List<Object> get props => [messages, conversationId];
}

class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  List<Object> get props => [message];
}

// Cubit
class ChatCubit extends Cubit<ChatState> {
  final GetConversations getConversations;
  final GetMessages getMessages;
  final SendMessage sendMessage;

  ChatCubit({
    required this.getConversations,
    required this.getMessages,
    required this.sendMessage,
  }) : super(ChatInitial());

  Future<void> loadConversations() async {
    emit(ChatLoading());

    final result = await getConversations();

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (conversations) => emit(ConversationsLoaded(conversations: conversations)),
    );
  }

  Future<void> loadMessages(String conversationId) async {
    emit(ChatLoading());

    final result = await getMessages(GetMessagesParams(conversationId: conversationId));

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (messages) => emit(MessagesLoaded(
        messages: messages,
        conversationId: conversationId,
      )),
    );
  }

  Future<void> sendTextMessage({
    required String conversationId,
    required String content,
  }) async {
    final result = await sendMessage(SendMessageParams(
      conversationId: conversationId,
      content: content,
      type: MessageType.text,
    ));

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (message) {
        // Reload messages to show the new one
        loadMessages(conversationId);
      },
    );
  }
}