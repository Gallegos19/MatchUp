// lib/features/authentication/data/models/user_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  final String? token;

  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.age,
    required super.career,
    required super.semester,
    required super.campus,
    required super.bio,
    required super.interests,
    required super.photoUrls,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
    required super.isProfileComplete,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle different API response structures
    final userData = json['user'] ?? json;
    
    return UserModel(
      id: userData['id'] ?? '',
      email: userData['email'] ?? '',
      name: _buildFullName(userData),
      age: _calculateAge(userData['dateOfBirth']),
      career: userData['academicProfile']?['career'] ?? userData['career'],
      semester: _parseSemester(userData['academicProfile']?['semester'] ?? userData['semester']),
      campus: userData['academicProfile']?['campus'] ?? userData['campus'] ?? '',
      bio: userData['bio'],
      interests: _parseInterests(userData['interests']),
      photoUrls: _parsePhotoUrls(userData['photos'] ?? userData['photoUrls']),
      createdAt: _parseDateTime(userData['createdAt']),
      updatedAt: _parseDateTime(userData['updatedAt']),
      isActive: userData['isActive'] ?? true,
      isProfileComplete: userData['isProfileComplete'] ?? false,
      token: json['token'],
    );
  }

  static String _buildFullName(Map<String, dynamic> userData) {
    final firstName = userData['firstName'] ?? '';
    final lastName = userData['lastName'] ?? '';
    final fullName = userData['name'];
    
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }
    
    return '$firstName $lastName'.trim();
  }

  static int? _calculateAge(dynamic dateOfBirth) {
    if (dateOfBirth == null) return null;
    
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
      return null;
    }
  }

  static String? _parseSemester(dynamic semester) {
    if (semester == null) return null;
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
    
    return [];
  }

  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    
    try {
      return DateTime.parse(dateTime.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  UserModel copyWithToken(String token) {
    return UserModel(
      id: id,
      email: email,
      name: name,
      age: age,
      career: career,
      semester: semester,
      campus: campus,
      bio: bio,
      interests: interests,
      photoUrls: photoUrls,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      isProfileComplete: isProfileComplete,
      token: token,
    );
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      age: user.age,
      career: user.career,
      semester: user.semester,
      campus: user.campus,
      bio: user.bio,
      interests: user.interests,
      photoUrls: user.photoUrls,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isActive: user.isActive,
      isProfileComplete: user.isProfileComplete,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      age: age,
      career: career,
      semester: semester,
      campus: campus,
      bio: bio,
      interests: interests,
      photoUrls: photoUrls,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      isProfileComplete: isProfileComplete,
    );
  }
}