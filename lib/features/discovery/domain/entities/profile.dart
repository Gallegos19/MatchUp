// lib/features/discovery/domain/entities/profile.dart
import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String userId;
  final String name;
  final int age;
  final String career;
  final String semester;
  final String campus;
  final String? bio;
  final List<String> interests;
  final List<String> photoUrls;
  final double? distance;
  final bool isActive;
  final DateTime lastSeen;
  final bool isVerified;

  const Profile({
    required this.id,
    required this.userId,
    required this.name,
    required this.age,
    required this.career,
    required this.semester,
    required this.campus,
    this.bio,
    this.interests = const [],
    this.photoUrls = const [],
    this.distance,
    this.isActive = true,
    required this.lastSeen,
    this.isVerified = false,
  });

  Profile copyWith({
    String? id,
    String? userId,
    String? name,
    int? age,
    String? career,
    String? semester,
    String? campus,
    String? bio,
    List<String>? interests,
    List<String>? photoUrls,
    double? distance,
    bool? isActive,
    DateTime? lastSeen,
    bool? isVerified,
  }) {
    return Profile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      career: career ?? this.career,
      semester: semester ?? this.semester,
      campus: campus ?? this.campus,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      photoUrls: photoUrls ?? this.photoUrls,
      distance: distance ?? this.distance,
      isActive: isActive ?? this.isActive,
      lastSeen: lastSeen ?? this.lastSeen,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  String get primaryPhotoUrl => photoUrls.isNotEmpty ? photoUrls.first : '';
  
  String get ageAndCareer => '$age años • $career';
  
  String get semesterAndCampus => '$semester semestre • $campus';
  
  bool get hasPhotos => photoUrls.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        age,
        career,
        semester,
        campus,
        bio,
        interests,
        photoUrls,
        distance,
        isActive,
        lastSeen,
        isVerified,
      ];
}