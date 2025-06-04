// lib/features/discovery/domain/repositories/discovery_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/discovery_filters.dart';
import '../entities/swipe_action.dart';
import '../entities/profile.dart';
import '../../../../core/errors/failures.dart';

abstract class DiscoveryRepository {
  Future<Either<Failure, DiscoveryFilters>> getFilters();

  Future<Either<Failure, void>> updateFilters({
    required DiscoveryFilters filters,
  });

  Future<Either<Failure, List<Profile>>> getProfiles({
    DiscoveryFilters? filters,
    int page,
    int limit,
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

  Future<Either<Failure, List<Profile>>> getLikedProfiles({
    int page,
    int limit,
  });

  Future<Either<Failure, List<Profile>>> getPassedProfiles({
    int page,
    int limit,
  });

  Future<Either<Failure, void>> undoLastSwipe();
}