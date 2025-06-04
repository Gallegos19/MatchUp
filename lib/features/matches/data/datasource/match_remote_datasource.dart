import '../models/match_user_model.dart';

abstract class MatchRemoteDatasource {
  Future<List<MatchUserModel>> getPotentialMatches();
}
