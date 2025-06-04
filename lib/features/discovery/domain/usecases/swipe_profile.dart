import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:matchup/features/discovery/domain/repositories/discovery_repository.dart';
import 'package:matchup/features/discovery/domain/entities/swipe_action.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';

class SwipeProfile implements UseCase<bool, SwipeProfileParams> {
  final DiscoveryRepository repository;

  SwipeProfile(this.repository);

  @override
  Future<Either<Failure, bool>> call(SwipeProfileParams params) async {
    return await repository.swipeProfile(
      profileId: params.profileId,
      action: params.action,
    );
  }
}

class SwipeProfileParams extends Equatable {
  final String profileId;
  final SwipeAction action;

  const SwipeProfileParams({
    required this.profileId,
    required this.action,
  });

  @override
  List<Object> get props => [profileId, action];
}
