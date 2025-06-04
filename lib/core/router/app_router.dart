// lib/core/router/app_router.dart - PROFILE INTEGRATION FIX

// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matchup/core/navigation/cubit/navigation_cubit.dart';
import 'package:matchup/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:matchup/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:matchup/di/injection_container.dart';
import 'package:matchup/features/discovery/presentation/cubit/discovery_cubit.dart';
import 'package:matchup/features/matches/presentation/viewmodels/match_viewmodel.dart';
import '../../features/authentication/presentation/pages/initial_session_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/discovery/presentation/pages/discovery_page.dart';
import '../../features/matches/presentation/pages/matches_page.dart';
import '../navigation/pages/main_navigation_page.dart';

class AppRouter {
  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String completeProfile = '/complete-profile';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: initial,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: initial,
        name: 'initial',
        builder: (context, state) => const InitialSessionPage(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => NavigationCubit()),
            BlocProvider(create: (_) => sl<DiscoveryCubit>()..loadProfiles()),
            ChangeNotifierProvider(create: (_) => sl<MatchViewModel>()..loadMatches()),
            BlocProvider(create: (_) => sl<ChatCubit>()..loadConversations()),
            BlocProvider(create: (_) => sl<ProfileCubit>()..getProfileData()),
          ],
          child: const MainNavigationPage(
            initialTab: NavigationTab.discovery,
          ),
        ),
      ),
      GoRoute(
        path: completeProfile,
        name: 'completeProfile',
        builder: (context, state) => const Placeholder(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const Placeholder(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Página no encontrada', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('La página "${state.uri.toString()}" no existe.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(initial),
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      ),
    ),
    redirect: (context, state) {
      // TODO: Validar autenticación
      return null;
    },
  );
}