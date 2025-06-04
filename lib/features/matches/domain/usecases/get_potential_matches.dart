import '../entities/match_user.dart';
import '../repositories/match_repository.dart';

class GetPotentialMatches {
  final MatchRepository repository;

  GetPotentialMatches(this.repository);

  Future<List<MatchUser>> call() async {
    return await repository.getPotentialMatches();
  }
}
