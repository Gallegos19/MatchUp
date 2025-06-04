// lib/core/navigation/pages/main_navigation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_colors.dart';
import '../../../features/discovery/presentation/pages/discovery_page.dart';
import '../cubit/navigation_cubit.dart';

class MainNavigationPage extends StatelessWidget {
  final NavigationTab initialTab;
  const MainNavigationPage({
    Key? key,
    this.initialTab = NavigationTab.discovery, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: _buildCurrentPage(state.currentTab),
          bottomNavigationBar: _buildBottomNavigationBar(context, state),
        );
      },
    );
  }

  Widget _buildCurrentPage(NavigationTab currentTab) {
    switch (currentTab) {
      case NavigationTab.discovery:
        return const DiscoveryPage();
      case NavigationTab.events:
        return _buildPlaceholderPage(
          'Eventos',
          Icons.event,
          'Próximamente: Eventos universitarios',
        );
      case NavigationTab.matches:
        return _buildPlaceholderPage(
          'Conexiones',
          Icons.favorite,
          'Próximamente: Tus matches',
        );
      case NavigationTab.chat:
        return _buildPlaceholderPage(
          'Mensajes',
          Icons.chat_bubble,
          'Próximamente: Chat con tus matches',
        );
      case NavigationTab.profile:
        return _buildPlaceholderPage(
          'Perfil',
          Icons.person,
          'Próximamente: Tu perfil personal',
        );
    }
  }

  Widget _buildPlaceholderPage(
      String title, IconData icon, String description) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Text(
                '🚀 Funcionalidad en desarrollo',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(
      BuildContext context, NavigationState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                tab: NavigationTab.discovery,
                currentTab: state.currentTab,
                icon: Icons.explore,
                label: 'Descubrir',
              ),
              _buildNavItem(
                context: context,
                tab: NavigationTab.events,
                currentTab: state.currentTab,
                icon: Icons.event,
                label: 'Eventos',
              ),
              _buildNavItem(
                context: context,
                tab: NavigationTab.matches,
                currentTab: state.currentTab,
                icon: Icons.favorite,
                label: 'Conexiones',
              ),
              _buildNavItem(
                context: context,
                tab: NavigationTab.chat,
                currentTab: state.currentTab,
                icon: Icons.chat_bubble,
                label: 'Mensajes',
              ),
              _buildNavItem(
                context: context,
                tab: NavigationTab.profile,
                currentTab: state.currentTab,
                icon: Icons.person,
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required NavigationTab tab,
    required NavigationTab currentTab,
    required IconData icon,
    required String label,
  }) {
    final isSelected = tab == currentTab;

    return GestureDetector(
      onTap: () => context.read<NavigationCubit>().changeTab(tab),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? Colors.white : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textHint,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
