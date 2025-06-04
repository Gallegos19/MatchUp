import '../../domain/entities/match_user.dart';

class MatchUserModel extends MatchUser {
  MatchUserModel({
    required super.id,
    required super.name,
    required super.age,
    required super.career,
    required super.imageUrl,
  });

  factory MatchUserModel.fromJson(Map<String, dynamic> json) {
    return MatchUserModel(
      id: json['id'],
      name: '${json['firstName']} ${json['lastName']}',
      age: _calculateAge(DateTime.parse(json['dateOfBirth'])),
      career: json['career'],
      imageUrl: json['profilePicture'] ?? 'https://via.placeholder.com/150',
    );
  }

  static int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
