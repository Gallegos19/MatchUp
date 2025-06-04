// lib/features/chat/domain/entities/conversation.dart
import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final String id;
  final String matchId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhoto;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isActive;

  const Conversation({
    required this.id,
    required this.matchId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhoto,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        matchId,
        otherUserId,
        otherUserName,
        otherUserPhoto,
        lastMessage,
        lastMessageTime,
        unreadCount,
        isActive,
      ];
}

