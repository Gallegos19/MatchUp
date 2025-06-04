import '../entities/match_user.dart';

abstract class MatchRepository {
  Future<List<MatchUser>> getPotentialMatches();
}
