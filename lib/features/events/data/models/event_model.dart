// lib/features/events/data/models/event_model.dart - UPDATED
import 'dart:convert';
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
    print('🔍 Parseando evento JSON: $json'); // Debug

    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: _parseEventType(json['event_type'] ?? json['eventType'] ?? json['type']),
      location: json['location'] ?? '',
      campus: json['campus'] ?? '',
      startDate: _parseDateTime(json['start_date'] ?? json['startDate']),
      endDate: _parseDateTime(json['end_date'] ?? json['endDate']),
      maxParticipants: _parseInt(json['max_participants'] ?? json['maxParticipants']) ?? 0,
      currentParticipants: _parseInt(json['current_participants'] ?? json['currentParticipants']) ?? 0,
      isPublic: _parseBool(json['is_public'] ?? json['isPublic']) ?? true,
      authorId: json['creator_id'] ?? json['authorId'] ?? json['creatorId'] ?? '',
      authorName: _buildAuthorName(json),
      tags: _parseTags(json['tags']),
      requirements: _parseRequirements(json['requirements']),
      isJoined: _parseBool(json['is_joined'] ?? json['isJoined']) ?? false,
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
    );
  }

  static EventType _parseEventType(String? type) {
    if (type == null) return EventType.social;
    
    switch (type.toLowerCase()) {
      case 'academic':
        return EventType.academic;
      case 'sports':
      case 'sport':
        return EventType.sports;
      case 'cultural':
      case 'culture':
        return EventType.cultural;
      case 'networking':
        return EventType.networking;
      case 'social':
      default:
        return EventType.social;
    }
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    
    if (dateValue is DateTime) return dateValue;
    
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        print('🔍 Error parseando fecha: $dateValue - $e');
        return DateTime.now();
      }
    }
    
    return DateTime.now();
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    if (value is int) {
      return value == 1;
    }
    return null;
  }

  static String _buildAuthorName(Map<String, dynamic> json) {
    // Intentar diferentes estructuras según tu backend
    
    // Si tiene creatorInfo separado
    final creatorInfo = json['creatorInfo'];
    if (creatorInfo != null) {
      final firstName = creatorInfo['firstName'] ?? '';
      final lastName = creatorInfo['lastName'] ?? '';
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      }
    }

    // Si tiene campos directos del JOIN
    final creatorFirstName = json['creator_first_name'];
    final creatorLastName = json['creator_last_name'];
    if (creatorFirstName != null || creatorLastName != null) {
      return '$creatorFirstName $creatorLastName'.trim();
    }

    // Si tiene author object
    final author = json['author'];
    if (author != null) {
      final firstName = author['firstName'] ?? author['first_name'] ?? '';
      final lastName = author['lastName'] ?? author['last_name'] ?? '';
      final fullName = author['name'];
      
      if (fullName != null && fullName.isNotEmpty) {
        return fullName;
      }
      
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        return '$firstName $lastName'.trim();
      }
    }

    // Campos directos
    final firstName = json['firstName'] ?? json['first_name'] ?? '';
    final lastName = json['lastName'] ?? json['last_name'] ?? '';
    final authorName = json['authorName'] ?? json['author_name'] ?? '';

    if (authorName.isNotEmpty) return authorName;
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }

    return 'Organizador';
  }

  static List<String> _parseTags(dynamic tags) {
    if (tags == null) return [];
    
    if (tags is List) {
      return tags.map((e) => e.toString()).toList();
    }
    
    if (tags is String) {
      try {
        // Si es un JSON string, parsearlo
        if (tags.startsWith('[') && tags.endsWith(']')) {
          final decoded = json.decode(tags);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        }
        // Si es un string separado por comas
        return tags.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      } catch (e) {
        print('🔍 Error parseando tags: $tags - $e');
        return [];
      }
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
            value: req['value'] ?? req['min_semester'] ?? req['minSemester'] ?? req['min_gpa'] ?? req['minGpa'],
          );
        }
        return const EventRequirement(type: '', value: null);
      }).where((req) => req.type.isNotEmpty).toList();
    }
    
    if (requirements is String) {
      try {
        // Si es un JSON string, parsearlo
        if (requirements.startsWith('[') && requirements.endsWith(']')) {
          final decoded = json.decode(requirements);
          if (decoded is List) {
            return _parseRequirements(decoded);
          }
        }
      } catch (e) {
        print('🔍 Error parseando requirements: $requirements - $e');
      }
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