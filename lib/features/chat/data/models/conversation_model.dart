
// lib/features/chat/data/models/conversation_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/conversation.dart';

part 'conversation_model.g.dart';

@JsonSerializable()
class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.matchId,
    required super.otherUserId,
    required super.otherUserName,
    super.otherUserPhoto,
    super.lastMessage,
    super.lastMessageTime,
    super.unreadCount = 0,
    super.isActive = true,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? '',
      matchId: json['matchId'] ?? '',
      otherUserId: json['otherUser']?['id'] ?? '',
      otherUserName: _buildUserName(json['otherUser']),
      otherUserPhoto: json['otherUser']?['profilePicture'],
      lastMessage: json['lastMessage']?['content'],
      lastMessageTime: json['lastMessage']?['timestamp'] != null 
          ? DateTime.parse(json['lastMessage']['timestamp'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  static String _buildUserName(Map<String, dynamic>? otherUser) {
    if (otherUser == null) return 'Usuario';
    
    final firstName = otherUser['firstName'] ?? '';
    final lastName = otherUser['lastName'] ?? '';
    final fullName = otherUser['name'];
    
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }
    
    return '$firstName $lastName'.trim();
  }

  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);

  Conversation toEntity() {
    return Conversation(
      id: id,
      matchId: matchId,
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      otherUserPhoto: otherUserPhoto,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
      isActive: isActive,
    );
  }
}
