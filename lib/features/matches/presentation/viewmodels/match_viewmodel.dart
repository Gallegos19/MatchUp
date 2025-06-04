import 'package:flutter/material.dart';
import '../../domain/entities/match_user.dart';
import '../../domain/usecases/get_potential_matches.dart';

class MatchViewModel extends ChangeNotifier {
  final GetPotentialMatches getPotentialMatchesUsecase;

  MatchViewModel(this.getPotentialMatchesUsecase);

  List<MatchUser> matches = [];
  bool isLoading = false;
  String? error;

  Future<void> loadMatches() async {
    isLoading = true;
    notifyListeners();

    try {
      matches = await getPotentialMatchesUsecase();
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
