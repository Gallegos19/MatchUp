import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matchup/features/events/presentation/pages/event_page.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../../features/discovery/presentation/pages/discovery_page.dart';
import '../../../features/matches/presentation/pages/matches_page.dart';
import '../../../features/chat/presentation/pages/chat_page.dart';
import '../../../features/profile/presentation/pages/profile_page.dart';
import '../../../features/matches/presentation/viewmodels/match_viewmodel.dart';
import '../../../features/events/presentation/cubit/events_cubit.dart';
import '../../../features/chat/presentation/cubit/chat_cubit.dart';
import '../../../di/injection_container.dart' as di;
import '../cubit/navigation_cubit.dart';

class MainNavigationPage extends StatelessWidget {
  final NavigationTab initialTab;
  const MainNavigationPage({
    Key? key,
    this.initialTab = NavigationTab.discovery, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: context.read<NavigationCubit>(),
        ),
        BlocProvider(
          create: (_) => di.sl<EventsCubit>(),
        ),
        BlocProvider(
          create: (_) => di.sl<ChatCubit>(),
        ),
        ChangeNotifierProvider(
          create: (_) => di.sl<MatchViewModel>(),
        ),
      ],
      child: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) {
          return Scaffold(
            body: _buildCurrentPage(state.currentTab),
            bottomNavigationBar: _buildBottomNavigationBar(context, state),
          );
        },
      ),
    );
  }

  Widget _buildCurrentPage(NavigationTab currentTab) {
    switch (currentTab) {
      case NavigationTab.discovery:
        return const DiscoveryPage();
      case NavigationTab.events:
        return const EventsPage();
      case NavigationTab.matches:
        return const MatchesPage();
      case NavigationTab.chat:
        return const ChatPage();
      case NavigationTab.profile:
        return const ProfilePage();
    }
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
                badgeCount: 3, // TODO: Get from actual data
              ),
              _buildNavItem(
                context: context,
                tab: NavigationTab.chat,
                currentTab: state.currentTab,
                icon: Icons.chat_bubble,
                label: 'Mensajes',
                badgeCount: 5, // TODO: Get from actual data
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
    int badgeCount = 0,
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
            Stack(
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
                if (badgeCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
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