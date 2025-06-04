import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final int? age;
  final String? career;
  final String? semester;
  final String? campus;
  final String? bio;
  final List<String> interests;
  final List<String> photoUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isProfileComplete;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.age,
    this.career,
    this.semester,
    this.campus,
    this.bio,
    this.interests = const [],
    this.photoUrls = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isProfileComplete = false,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    int? age,
    String? career,
    String? semester,
    String? campus,
    String? bio,
    List<String>? interests,
    List<String>? photoUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isProfileComplete,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      career: career ?? this.career,
      semester: semester ?? this.semester,
      campus: campus ?? this.campus,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        age,
        career,
        semester,
        campus,
        bio,
        interests,
        photoUrls,
        createdAt,
        updatedAt,
        isActive,
        isProfileComplete,
      ];
}