import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:matchup/features/discovery/domain/entities/discovery_filters.dart';
import 'package:matchup/features/discovery/domain/entities/swipe_action.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/get_profiles.dart';
import '../../domain/usecases/swipe_profile.dart';
import '../../domain/usecases/get_profile_details.dart';

// States
abstract class DiscoveryState extends Equatable {
  const DiscoveryState();

  @override
  List<Object?> get props => [];
}

class DiscoveryInitial extends DiscoveryState {}

class DiscoveryLoading extends DiscoveryState {}

class DiscoveryLoaded extends DiscoveryState {
  final List<Profile> profiles;
  final bool hasReachedMax;
  final DiscoveryFilters? currentFilters;

  const DiscoveryLoaded({
    required this.profiles,
    this.hasReachedMax = false,
    this.currentFilters,
  });

  DiscoveryLoaded copyWith({
    List<Profile>? profiles,
    bool? hasReachedMax,
    DiscoveryFilters? currentFilters,
  }) {
    return DiscoveryLoaded(
      profiles: profiles ?? this.profiles,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentFilters: currentFilters ?? this.currentFilters,
    );
  }

  @override
  List<Object?> get props => [profiles, hasReachedMax, currentFilters];
}

class DiscoveryError extends DiscoveryState {
  final String message;

  const DiscoveryError({required this.message});

  @override
  List<Object> get props => [message];
}

class DiscoverySwipeSuccess extends DiscoveryState {
  final bool isMatch;
  final Profile? matchedProfile;

  const DiscoverySwipeSuccess({
    required this.isMatch,
    this.matchedProfile,
  });

  @override
  List<Object?> get props => [isMatch, matchedProfile];
}

// Cubit
class DiscoveryCubit extends Cubit<DiscoveryState> {
  final GetProfiles getProfiles;
  final SwipeProfile swipeProfile;
  final GetProfileDetails getProfileDetails;

  DiscoveryCubit({
    required this.getProfiles,
    required this.swipeProfile,
    required this.getProfileDetails,
  }) : super(DiscoveryInitial());

  // Current state management
  int _currentPage = 1;
  DiscoveryFilters? _currentFilters;
  final List<Profile> _profiles = [];

  // Getters
  bool get isLoading => state is DiscoveryLoading;
  List<Profile> get profiles => _profiles;
  Profile? get currentProfile => _profiles.isNotEmpty ? _profiles.first : null;
  bool get hasProfiles => _profiles.isNotEmpty;

  // Load initial profiles
  Future<void> loadProfiles({DiscoveryFilters? filters}) async {
    emit(DiscoveryLoading());
    
    _currentPage = 1;
    _currentFilters = filters;
    _profiles.clear();

    final result = await getProfiles(GetProfilesParams(
      filters: filters,
      page: _currentPage,
      limit: 10,
    ));

    result.fold(
      (failure) => emit(DiscoveryError(message: _getFailureMessage(failure))),
      (profiles) {
        _profiles.addAll(profiles);
        emit(DiscoveryLoaded(
          profiles: List.from(_profiles),
          hasReachedMax: profiles.length < 10,
          currentFilters: _currentFilters,
        ));
      },
    );
  }

  // Load more profiles (pagination)
  Future<void> loadMoreProfiles() async {
    if (state is! DiscoveryLoaded) return;
    
    final currentState = state as DiscoveryLoaded;
    if (currentState.hasReachedMax) return;

    _currentPage++;

    final result = await getProfiles(GetProfilesParams(
      filters: _currentFilters,
      page: _currentPage,
      limit: 10,
    ));

    result.fold(
      (failure) => emit(DiscoveryError(message: _getFailureMessage(failure))),
      (newProfiles) {
        _profiles.addAll(newProfiles);
        emit(currentState.copyWith(
          profiles: List.from(_profiles),
          hasReachedMax: newProfiles.length < 10,
        ));
      },
    );
  }

  // Handle swipe actions
  Future<void> handleSwipe({
    required String profileId,
    required SwipeAction action,
  }) async {
    // Remove the swiped profile from local list immediately
    _profiles.removeWhere((profile) => profile.id == profileId);
    
    // Update UI immediately
    if (state is DiscoveryLoaded) {
      final currentState = state as DiscoveryLoaded;
      emit(currentState.copyWith(profiles: List.from(_profiles)));
    }

    // Send swipe to server
    final result = await swipeProfile(SwipeProfileParams(
      profileId: profileId,
      action: action,
    ));

    result.fold(
      (failure) {
        // If swipe fails, you might want to add the profile back
        // For now, just show error but keep profile removed
        emit(DiscoveryError(message: _getFailureMessage(failure)));
      },
      (isMatch) {
        if (isMatch && action == SwipeAction.like) {
          // Handle match - show match screen
          emit(const DiscoverySwipeSuccess(isMatch: true));
        }
        
        // Load more profiles if we're running low
        if (_profiles.length < 3) {
          loadMoreProfiles();
        }
      },
    );
  }

  // Apply filters
  Future<void> applyFilters(DiscoveryFilters filters) async {
    await loadProfiles(filters: filters);
  }

  // Clear filters
  Future<void> clearFilters() async {
    await loadProfiles();
  }

  // Refresh profiles
  Future<void> refreshProfiles() async {
    await loadProfiles(filters: _currentFilters);
  }

  // Get profile details
  Future<void> getProfileDetailById(String profileId) async {
    final result = await getProfileDetails(
      GetProfileDetailsParams(profileId: profileId),
    );

    result.fold(
      (failure) => emit(DiscoveryError(message: _getFailureMessage(failure))),
      (profile) {
        // You can emit a specific state for profile details if needed
        // For now, we'll handle this in the UI
      },
    );
  }

  // Reset after showing match
  void resetAfterMatch() {
    if (_profiles.isNotEmpty) {
      emit(DiscoveryLoaded(
        profiles: List.from(_profiles),
        currentFilters: _currentFilters,
      ));
    } else {
      loadMoreProfiles();
    }
  }

  String _getFailureMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'Error de conexión. Verifica tu internet';
      case ServerFailure:
        return 'Error del servidor. Intenta más tarde';
      case UnauthorizedFailure:
        return 'Sesión expirada. Inicia sesión nuevamente';
      default:
        return failure.message.isNotEmpty 
            ? failure.message 
            : 'Ha ocurrido un error inesperado';
    }
  }
}