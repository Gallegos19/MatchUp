import '../../domain/entities/match_user.dart';
import '../../domain/repositories/match_repository.dart';
import '../datasource/match_remote_datasource.dart';

class MatchRepositoryImpl implements MatchRepository {
  final MatchRemoteDatasource remoteDatasource;

  MatchRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<MatchUser>> getPotentialMatches() {
    return remoteDatasource.getPotentialMatches();
  }
}
