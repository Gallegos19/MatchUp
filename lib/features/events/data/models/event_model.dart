import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/event.dart';

part 'event_model.g.dart';

@JsonSerializable()
class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.location,
    required super.campus,
    required super.startDate,
    required super.endDate,
    required super.maxParticipants,
    super.currentParticipants = 0,
    super.isPublic = true,
    required super.authorId,
    required super.authorName,
    super.tags = const [],
    super.requirements = const [],
    super.isJoined = false,
    required super.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: _parseEventType(json['eventType'] ?? json['type']),
      location: json['location'] ?? '',
      campus: json['campus'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      maxParticipants: json['maxParticipants'] ?? 0,
      currentParticipants: json['currentParticipants'] ?? 0,
      isPublic: json['isPublic'] ?? true,
      authorId: json['authorId'] ?? json['author']?['id'] ?? '',
      authorName: _buildAuthorName(json['author']),
      tags: _parseTags(json['tags']),
      requirements: _parseRequirements(json['requirements']),
      isJoined: json['isJoined'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static EventType _parseEventType(String? type) {
    switch (type?.toLowerCase()) {
      case 'academic':
        return EventType.academic;
      case 'sports':
        return EventType.sports;
      case 'cultural':
        return EventType.cultural;
      case 'networking':
        return EventType.networking;
      default:
        return EventType.social;
    }
  }

  static String _buildAuthorName(Map<String, dynamic>? author) {
    if (author == null) return 'Organizador';
    
    final firstName = author['firstName'] ?? '';
    final lastName = author['lastName'] ?? '';
    final fullName = author['name'];
    
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }
    
    return '$firstName $lastName'.trim();
  }

  static List<String> _parseTags(dynamic tags) {
    if (tags == null) return [];
    
    if (tags is List) {
      return tags.map((e) => e.toString()).toList();
    }
    
    return [];
  }

  static List<EventRequirement> _parseRequirements(dynamic requirements) {
    if (requirements == null) return [];
    
    if (requirements is List) {
      return requirements.map((req) {
        if (req is Map<String, dynamic>) {
          return EventRequirement(
            type: req['type'] ?? '',
            value: req['value'] ?? req['minSemester'] ?? req['minGpa'],
          );
        }
        return const EventRequirement(type: '', value: null);
      }).toList();
    }
    
    return [];
  }

  Map<String, dynamic> toJson() => _$EventModelToJson(this);

  Event toEntity() {
    return Event(
      id: id,
      title: title,
      description: description,
      type: type,
      location: location,
      campus: campus,
      startDate: startDate,
      endDate: endDate,
      maxParticipants: maxParticipants,
      currentParticipants: currentParticipants,
      isPublic: isPublic,
      authorId: authorId,
      authorName: authorName,
      tags: tags,
      requirements: requirements,
      isJoined: isJoined,
      createdAt: createdAt,
    );
  }
}