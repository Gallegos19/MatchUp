import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../cubit/discovery_cubit.dart';
import '../widgets/swipe_cards.dart';
import '../widgets/discovery_action_buttons.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({Key? key}) : super(key: key);

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  // Remove the GlobalKey since we don't need it - we'll access methods differently
  
  @override
  void initState() {
    super.initState();
    // Load initial profiles
    context.read<DiscoveryCubit>().loadProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<DiscoveryCubit, DiscoveryState>(
          listener: (context, state) {
            if (state is DiscoveryError) {
              _showErrorSnackBar(state.message);
            } else if (state is DiscoverySwipeSuccess) {
              if (state.isMatch) {
                _showMatchDialog(state.matchedProfile);
              }
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Top App Bar
                _buildTopAppBar(),
                
                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // Cards Stack
                        Expanded(
                          child: _buildCardsSection(state),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Action Buttons
                        _buildActionButtons(state),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 18,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Title
          const Text(
            AppStrings.appName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const Spacer(),
          
          // Filter button
          IconButton(
            onPressed: _showFiltersBottomSheet,
            icon: const Icon(
              Icons.tune,
              color: AppColors.textSecondary,
            ),
          ),
          
          // Profile button
          IconButton(
            onPressed: _navigateToProfile,
            icon: const Icon(
              Icons.person,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsSection(DiscoveryState state) {
    if (state is DiscoveryLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (state is DiscoveryError) {
      return _buildErrorState(state.message);
    }

    if (state is DiscoveryLoaded) {
      return SwipeCards(
        profiles: state.profiles,
        onSwipe: _handleSwipe,
        onProfileTap: _showProfileDetails,
        onEmptyStack: _handleEmptyStack,
      );
    }

    return _buildErrorState('Estado desconocido');
  }

  Widget _buildErrorState(String message) {
    return Container(
      height: 600,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderLight,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Ups, algo salió mal',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(DiscoveryState state) {
    final hasProfiles = state is DiscoveryLoaded && state.profiles.isNotEmpty;

    return DiscoveryActionButtons(
      onRewind: hasProfiles ? _handleRewind : null,
      onDislike: hasProfiles ? _handleDislike : null,
      onSuperLike: hasProfiles ? _handleSuperLike : null,
      onLike: hasProfiles ? _handleLike : null,
      onBoost: hasProfiles ? _handleBoost : null,
    );
  }

  // Action handlers
  void _handleSwipe(String profileId, SwipeAction action) {
    context.read<DiscoveryCubit>().handleSwipe(
      profileId: profileId,
      action: action,
    );
  }

  void _handleRewind() {
    // TODO: Implement rewind functionality
    _showFeatureNotAvailable('Rewind');
  }

  void _handleDislike() {
    // Trigger dislike action through the cubit
    final cubit = context.read<DiscoveryCubit>();
    if (cubit.currentProfile != null) {
      cubit.handleSwipe(
        profileId: cubit.currentProfile!.id,
        action: SwipeAction.dislike,
      );
    }
  }

  void _handleSuperLike() {
    final cubit = context.read<DiscoveryCubit>();
    if (cubit.currentProfile != null) {
      cubit.handleSwipe(
        profileId: cubit.currentProfile!.id,
        action: SwipeAction.superLike,
      );
    }
  }

  void _handleLike() {
    // Trigger like action through the cubit
    final cubit = context.read<DiscoveryCubit>();
    if (cubit.currentProfile != null) {
      cubit.handleSwipe(
        profileId: cubit.currentProfile!.id,
        action: SwipeAction.like,
      );
    }
  }

  void _handleBoost() {
    // TODO: Implement boost functionality
    _showFeatureNotAvailable('Boost');
  }

  void _handleEmptyStack() {
    context.read<DiscoveryCubit>().refreshProfiles();
  }

  void _retry() {
    context.read<DiscoveryCubit>().loadProfiles();
  }

  // Navigation and dialogs
  void _showProfileDetails() {
    final cubit = context.read<DiscoveryCubit>();
    if (cubit.currentProfile != null) {
      // TODO: Navigate to profile details page
      _showFeatureNotAvailable('Ver perfil completo');
    }
  }

  void _showFiltersBottomSheet() {
    // TODO: Implement filters bottom sheet
    _showFeatureNotAvailable('Filtros');
  }

  void _navigateToProfile() {
    // TODO: Navigate to user profile
    _showFeatureNotAvailable('Mi perfil');
  }

  void _showMatchDialog(Profile? matchedProfile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite,
              size: 80,
              color: AppColors.like,
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Es un Match!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (matchedProfile != null) ...[
              const SizedBox(height: 8),
              Text(
                'Tú y ${matchedProfile.name} se han gustado',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.read<DiscoveryCubit>().resetAfterMatch();
                    },
                    child: const Text('Seguir viendo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: Navigate to chat
                      _showFeatureNotAvailable('Chat');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Enviar mensaje'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFeatureNotAvailable(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature estará disponible próximamente'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}