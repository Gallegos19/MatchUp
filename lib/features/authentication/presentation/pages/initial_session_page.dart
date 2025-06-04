import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/custom_button.dart';
// Asegúrate de importar las páginas de Login y Register si usas Navigator.push
import '../pages/login_page.dart';
import '../pages/register_page.dart';

class InitialSessionPage extends StatelessWidget {
  const InitialSessionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildHeader(),
                const Spacer(flex: 3),
                _buildActionButtons(context),
                const SizedBox(height: 40),
                _buildTermsAndConditions(context),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite,
            size: 60,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          AppStrings.appDescription,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: AppStrings.login,
          onPressed: () {
            print("Login button pressed");
            context.go(AppRouter.login);
          },
          type: ButtonType.secondary,
          width: double.infinity,
          height: 56,
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: AppStrings.createAccount,
          onPressed: () => context.go(AppRouter.register),
          type: ButtonType.outline,
          width: double.infinity,
          height: 56,
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions(BuildContext context) {
    return Column(
      children: [
        Text(
          'Al continuar, aceptas nuestros',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _showTermsOfService(context),
              child: const Text(
                'Términos de Servicio',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(
              ' y ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            GestureDetector(
              onTap: () => _showPrivacyPolicy(context),
              child: const Text(
                'Política de Privacidad',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showTermsOfService(BuildContext context) {
    // TODO: Implementar navegación a términos de servicio
  }

  void _showPrivacyPolicy(BuildContext context) {
    // TODO: Implementar navegación a política de privacidad
  }
}
