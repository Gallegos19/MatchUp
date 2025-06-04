// lib/features/discovery/data/models/profile_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/profile.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class ProfileModel extends Profile {
  const ProfileModel({
    required String id,
    required String userId,
    required String name,
    required int age,
    required String career,
    required String semester,
    required String campus,
    String? bio,
    List<String> interests = const [],
    List<String> photoUrls = const [],
    double? distance,
    bool isActive = true,
    required DateTime lastSeen,
    bool isVerified = false,
  }) : super(
          id: id,
          userId: userId,
          name: name,
          age: age,
          career: career,
          semester: semester,
          campus: campus,
          bio: bio,
          interests: interests,
          photoUrls: photoUrls,
          distance: distance,
          isActive: isActive,
          lastSeen: lastSeen,
          isVerified: isVerified,
        );

  factory ProfileModel.fromJson(Map<String, dynamic> json) => _$ProfileModelFromJson(json);

  // Factory for API response from matches/potential endpoint
  factory ProfileModel.fromMatchApiJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      userId: json['id'] ?? '', // Using same ID for user
      name: _buildFullName(json),
      age: _calculateAge(json['dateOfBirth']),
      career: json['academicProfile']?['career'] ?? json['career'] ?? 'No especificado',
      semester: _parseSemester(json['academicProfile']?['semester'] ?? json['semester']),
      campus: json['academicProfile']?['campus'] ?? json['campus'] ?? 'No especificado',
      bio: json['bio'],
      interests: _parseInterests(json['interests']),
      photoUrls: _parsePhotoUrls(json['photos'] ?? json['photoUrls']),
      distance: _parseDistance(json['distance']),
      isActive: json['isActive'] ?? true,
      lastSeen: _parseDateTime(json['lastSeen'] ?? json['updatedAt']),
      isVerified: json['isVerified'] ?? false,
    );
  }

  static String _buildFullName(Map<String, dynamic> json) {
    final firstName = json['firstName'] ?? '';
    final lastName = json['lastName'] ?? '';
    final fullName = json['name'];
    
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }
    
    return '$firstName $lastName'.trim();
  }

  static int _calculateAge(dynamic dateOfBirth) {
    if (dateOfBirth == null) return 20; // Default age
    
    try {
      final birthDate = DateTime.parse(dateOfBirth.toString());
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      
      return age;
    } catch (e) {
      return 20; // Default age
    }
  }

  static String _parseSemester(dynamic semester) {
    if (semester == null) return '1';
    return semester.toString();
  }

  static List<String> _parseInterests(dynamic interests) {
    if (interests == null) return [];
    
    if (interests is List) {
      return interests.map((e) => e.toString()).toList();
    }
    
    return [];
  }

  static List<String> _parsePhotoUrls(dynamic photos) {
    if (photos == null) return [];
    
    if (photos is List) {
      return photos.map((e) => e.toString()).toList();
    }
    
    // If no photos, return a placeholder
    return [
      'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400&h=600&fit=crop'
    ];
  }

  static double? _parseDistance(dynamic distance) {
    if (distance == null) return null;
    
    try {
      return double.parse(distance.toString());
    } catch (e) {
      return null;
    }
  }

  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    
    try {
      return DateTime.parse(dateTime.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);

  factory ProfileModel.fromEntity(Profile profile) {
    return ProfileModel(
      id: profile.id,
      userId: profile.userId,
      name: profile.name,
      age: profile.age,
      career: profile.career,
      semester: profile.semester,
      campus: profile.campus,
      bio: profile.bio,
      interests: profile.interests,
      photoUrls: profile.photoUrls,
      distance: profile.distance,
      isActive: profile.isActive,
      lastSeen: profile.lastSeen,
      isVerified: profile.isVerified,
    );
  }

  Profile toEntity() {
    return Profile(
      id: id,
      userId: userId,
      name: name,
      age: age,
      career: career,
      semester: semester,
      campus: campus,
      bio: bio,
      interests: interests,
      photoUrls: photoUrls,
      distance: distance,
      isActive: isActive,
      lastSeen: lastSeen,
      isVerified: isVerified,
    );
  }
}