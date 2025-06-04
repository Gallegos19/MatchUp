// lib/features/profile/presentation/pages/profile_page.dart - COMPLETE

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../authentication/presentation/cubit/auth_cubit.dart';
import '../cubit/profile_cubit.dart';
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
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              _showErrorSnackBar(context, state.message);
            } else if (state is ProfileSuccess) {
              _showSuccessSnackBar(context, state.message);
            }
          },
          builder: (context, profileState) {
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  return _buildProfileContent(context, authState.user, profileState);
                }
                
                return _buildUnauthenticatedState(context);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, user, ProfileState profileState) {
    if (profileState is ProfileLoading) {
      return _buildLoadingState();
    }

    return CustomScrollView(
      slivers: [
        _buildAppBar(context, profileState),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 20),
              ProfileHeader(
                user: profileState is ProfileLoaded ? profileState.profile : user,
                onEditPressed: () => _showEditProfileBottomSheet(context),
              ),
              const SizedBox(height: 24),
              ProfileStats(
                matchesCount: profileState is ProfileLoaded 
                    ? profileState.stats?.matchesCount ?? 0 
                    : 42,
                likesCount: profileState is ProfileLoaded 
                    ? profileState.stats?.likesReceived ?? 0 
                    : 128,
                superLikesCount: profileState is ProfileLoaded 
                    ? profileState.stats?.superLikesReceived ?? 0 
                    : 15,
                viewsCount: profileState is ProfileLoaded 
                    ? profileState.stats?.profileViews ?? 0 
                    : 256,
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

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Cargando perfil...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ProfileState profileState) {
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
        if (profileState is ProfileUpdating || profileState is ProfilePhotoUploading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          )
        else ...[
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
            onTap: () => _handlePhotoManagement(context),
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
            onTap: () => _handlePasswordChange(context),
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

  void _handlePhotoManagement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Gestionar fotos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Tomar foto'),
                subtitle: const Text('Usar cámara'),
                onTap: () {
                  Navigator.pop(context);
                  _showFeatureNotAvailable(context, 'Cámara');
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Seleccionar de galería'),
                subtitle: const Text('Elegir foto existente'),
                onTap: () {
                  Navigator.pop(context);
                  _showFeatureNotAvailable(context, 'Galería');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('Eliminar foto'),
                subtitle: const Text('Quitar foto actual'),
                onTap: () {
                  Navigator.pop(context);
                  _showFeatureNotAvailable(context, 'Eliminar foto');
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _handlePasswordChange(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final currentPasswordController = TextEditingController();
        final newPasswordController = TextEditingController();
        final confirmPasswordController = TextEditingController();
        final formKey = GlobalKey<FormState>();

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Cambiar contraseña'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña actual',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu contraseña actual';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nueva contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa la nueva contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_clock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirma la nueva contraseña';
                    }
                    if (value != newPasswordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                final isLoading = state is ProfilePasswordChanging;
                return ElevatedButton(
                  onPressed: isLoading ? null : () {
                    if (formKey.currentState?.validate() ?? false) {
                      context.read<ProfileCubit>().changeUserPassword(
                        currentPassword: currentPasswordController.text,
                        newPassword: newPasswordController.text,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Cambiar'),
                );
              },
            ),
          ],
        );
      },
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
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}