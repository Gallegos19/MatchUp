// lib/features/matches/presentation/pages/matches_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../viewmodels/match_viewmodel.dart';
import '../widgets/match_card.dart';
import '../widgets/match_grid_item.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({Key? key}) : super(key: key);

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchViewModel>().loadMatches();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<MatchViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                _buildAppBar(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNewMatchesTab(viewModel),
                      _buildAllMatchesTab(viewModel),
                      _buildLikedByMeTab(viewModel),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
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
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: AppColors.secondaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Conexiones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _toggleViewMode,
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: AppColors.textSecondary,
            ),
          ),
          IconButton(
            onPressed: _refreshMatches,
            icon: const Icon(
              Icons.refresh,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.secondary,
        labelColor: AppColors.secondary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Nuevos'),
          Tab(text: 'Todos'),
          Tab(text: 'Mis likes'),
        ],
      ),
    );
  }

  Widget _buildNewMatchesTab(MatchViewModel viewModel) {
    if (viewModel.isLoading && viewModel.matches.isEmpty) {
      return _buildLoadingState();
    }

    if (viewModel.error != null) {
      return _buildErrorState(viewModel.error!, viewModel);
    }

    // Filter new matches (last 7 days)
    final newMatches = viewModel.matches.where((match) {
      // Since we don't have a match date, we'll show all for now
      return true;
    }).toList();

    if (newMatches.isEmpty) {
      return _buildEmptyState(
        'No hay nuevas conexiones',
        'Sigue deslizando en Descubrir para encontrar más matches',
        Icons.favorite_border,
      );
    }

    return _buildMatchesList(newMatches, viewModel);
  }

  Widget _buildAllMatchesTab(MatchViewModel viewModel) {
    if (viewModel.isLoading && viewModel.matches.isEmpty) {
      return _buildLoadingState();
    }

    if (viewModel.error != null) {
      return _buildErrorState(viewModel.error!, viewModel);
    }

    if (viewModel.matches.isEmpty) {
      return _buildEmptyState(
        'No tienes conexiones aún',
        'Comienza a deslizar perfiles en Descubrir para hacer tu primer match',
        Icons.favorite_border,
      );
    }

    return _buildMatchesList(viewModel.matches, viewModel);
  }

  Widget _buildLikedByMeTab(MatchViewModel viewModel) {
    // This would show profiles that the user liked
    return _buildEmptyState(
      'Perfiles que te gustaron',
      'Próximamente: Ve todos los perfiles a los que diste like',
      Icons.thumb_up_outlined,
    );
  }

  Widget _buildMatchesList(List matches, MatchViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () => viewModel.loadMatches(),
      color: AppColors.secondary,
      child: _isGridView ? _buildGridView(matches) : _buildListView(matches),
    );
  }

  Widget _buildListView(List matches) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return MatchCard(
          name: match.name,
          age: match.age,
          career: match.career,
          imageUrl: match.imageUrl,
          onTap: () => _openChat(match),
          onSuperLike: () => _showFeatureNotAvailable('Super Like'),
        );
      },
    );
  }

  Widget _buildGridView(List matches) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return MatchGridItem(
          name: match.name,
          age: match.age,
          career: match.career,
          imageUrl: match.imageUrl,
          onTap: () => _openChat(match),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.secondary),
          SizedBox(height: 16),
          Text(
            'Cargando tus conexiones...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, MatchViewModel viewModel) {
    return Center(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => viewModel.loadMatches(),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Text(
              '💕 Encuentra tu match perfecto',
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Action methods
  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _refreshMatches() {
    context.read<MatchViewModel>().loadMatches();
  }

  void _openChat(dynamic match) {
    // TODO: Navigate to chat screen
    _showFeatureNotAvailable('Chat con ${match.name}');
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
}