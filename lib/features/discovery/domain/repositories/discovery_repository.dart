// lib/features/discovery/domain/repositories/discovery_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile.dart';

enum SwipeAction { like, dislike, superLike }

class DiscoveryFilters {
  final int? minAge;
  final int? maxAge;
  final List<String>? careers;
  final List<String>? semesters;
  final List<String>? campuses;
  final double? maxDistance;
  final List<String>? interests;

  const DiscoveryFilters({
    this.minAge,
    this.maxAge,
    this.careers,
    this.semesters,
    this.campuses,
    this.maxDistance,
    this.interests,
  });
}

abstract class DiscoveryRepository {
  Future<Either<Failure, List<Profile>>> getProfiles({
    DiscoveryFilters? filters,
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, bool>> swipeProfile({
    required String profileId,
    required SwipeAction action,
  });

  Future<Either<Failure, Profile>> getProfileDetails({
    required String profileId,
  });

  Future<Either<Failure, void>> reportProfile({
    required String profileId,
    required String reason,
  });

  Future<Either<Failure, void>> blockProfile({
    required String profileId,
  });

  Future<Either<Failure, DiscoveryFilters>> getFilters();

  Future<Either<Failure, void>> updateFilters({
    required DiscoveryFilters filters,
  });

  Future<Either<Failure, List<Profile>>> getLikedProfiles({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, List<Profile>>> getPassedProfiles({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, void>> undoLastSwipe();
}