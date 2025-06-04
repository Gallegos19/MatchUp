// lib/features/profile/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../authentication/presentation/cubit/auth_cubit.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/edit_profile_bottom_sheet.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return _buildProfileContent(context, state.user);
            }
            
            return _buildUnauthenticatedState(context);
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, user) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 20),
              ProfileHeader(
                user: user,
                onEditPressed: () => _showEditProfileBottomSheet(context),
              ),
              const SizedBox(height: 24),
              const ProfileStats(
                matchesCount: 42, // TODO: Get from actual data
                likesCount: 128,
                superLikesCount: 15,
                viewsCount: 256,
              ),
              const SizedBox(height: 32),
              _buildMenuSection(context),
              const SizedBox(height: 32),
              _buildSettingsSection(context),
              const SizedBox(height: 32),
              _buildLogoutButton(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      floating: true,
      snap: true,
      title: const Text(
        'Mi Perfil',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showEditProfileBottomSheet(context),
          icon: const Icon(
            Icons.edit,
            color: AppColors.textSecondary,
          ),
        ),
        IconButton(
          onPressed: () => _showSettingsPage(context),
          icon: const Icon(
            Icons.settings,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileMenuItem(
            icon: Icons.photo_library,
            title: 'Mis fotos',
            subtitle: 'Gestiona tus fotos de perfil',
            onTap: () => _showFeatureNotAvailable(context, 'Gestión de fotos'),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          ProfileMenuItem(
            icon: Icons.interests,
            title: 'Intereses',
            subtitle: 'Actualiza tus intereses',
            onTap: () => _showFeatureNotAvailable(context, 'Edición de intereses'),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          ProfileMenuItem(
            icon: Icons.location_on,
            title: 'Ubicación',
            subtitle: 'Configura tu ubicación',
            onTap: () => _showFeatureNotAvailable(context, 'Configuración de ubicación'),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          ProfileMenuItem(
            icon: Icons.school,
            title: 'Información académica',
            subtitle: 'Carrera, semestre y campus',
            onTap: () => _showFeatureNotAvailable(context, 'Información académica'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileMenuItem(
            icon: Icons.notifications,
            title: 'Notificaciones',
            subtitle: 'Configura tus notificaciones',
            onTap: () => _showFeatureNotAvailable(context, 'Configuración de notificaciones'),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          ProfileMenuItem(
            icon: Icons.privacy_tip,
            title: 'Privacidad',
            subtitle: 'Controla quién puede verte',
            onTap: () => _showFeatureNotAvailable(context, 'Configuración de privacidad'),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          ProfileMenuItem(
            icon: Icons.security,
            title: 'Seguridad',
            subtitle: 'Cambia tu contraseña',
            onTap: () => _showFeatureNotAvailable(context, 'Configuración de seguridad'),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          ProfileMenuItem(
            icon: Icons.help,
            title: 'Ayuda y soporte',
            subtitle: 'Centro de ayuda y contacto',
            onTap: () => _showFeatureNotAvailable(context, 'Centro de ayuda'),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          ProfileMenuItem(
            icon: Icons.info,
            title: 'Acerca de',
            subtitle: 'Versión de la app e información',
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout),
        label: const Text('Cerrar sesión'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 80,
            color: AppColors.textHint,
          ),
          SizedBox(height: 16),
          Text(
            'No has iniciado sesión',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Inicia sesión para ver tu perfil',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Action methods
  void _showEditProfileBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditProfileBottomSheet(),
    );
  }

  void _showSettingsPage(BuildContext context) {
    _showFeatureNotAvailable(context, 'Configuración avanzada');
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthCubit>().logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppStrings.appName,
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.favorite,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        const Text(
          'MatchUp es una aplicación para conectar estudiantes universitarios y facilitar la formación de grupos de estudio y eventos académicos.',
        ),
      ],
    );
  }

  void _showFeatureNotAvailable(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature estará disponible próximamente'),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}