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
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: '${json['firstName']} ${json['lastName']}',
      age: null,
      career: json['academicProfile']?['career'],
      semester: json['academicProfile']?['semester']?.toString(),
      campus: json['academicProfile']?['campus'],
      bio: null,
      interests: [],
      photoUrls: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
      isProfileComplete: json['isProfileComplete'] ?? false,
    );
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