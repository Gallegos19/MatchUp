
// lib/features/chat/data/models/message_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/message.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.content,
    required super.type,
    required super.timestamp,
    super.isRead = false,
    super.metadata,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      type: _parseMessageType(json['messageType'] ?? json['type']),
      timestamp: DateTime.parse(json['timestamp'] ?? json['createdAt']),
      isRead: json['isRead'] ?? false,
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  static MessageType _parseMessageType(String? type) {
    switch (type?.toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'study_invitation':
      case 'studyinvitation':
        return MessageType.studyInvitation;
      default:
        return MessageType.text;
    }
  }

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  Message toEntity() {
    return Message(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      content: content,
      type: type,
      timestamp: timestamp,
      isRead: isRead,
      metadata: metadata,
    );
  }
}
