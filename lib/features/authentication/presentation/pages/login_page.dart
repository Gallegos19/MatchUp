// lib/features/authentication/presentation/pages/login_page.dart - UPDATED
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:matchup/core/navigation/cubit/navigation_cubit.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/ui_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.go(AppRouter.initial),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticated) {
                  _showSuccessSnackBar();
                  context.go(AppRouter.home);
                  // Set initial navigation tab after successful login
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      context
                          .read<NavigationCubit>()
                          .changeTab(NavigationTab.discovery);
                    }
                  });
                } else if (state is AuthError) {
                  _showErrorSnackBar(state.message);
                } else if (state is AuthRegistrationSuccess) {
                  // Show the registration success message if user comes from registration
                  _showInfoSnackBar(state.message);
                  // Clear the registration success state
                  context.read<AuthCubit>().clearRegistrationSuccess();
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Header
                  _buildHeader(),

                  const SizedBox(height: 40),

                  // Form
                  _buildLoginForm(),

                  const SizedBox(height: 24),

                  // Forgot Password
                  _buildForgotPassword(),

                  const SizedBox(height: 32),

                  // Login Button
                  _buildLoginButton(),

                  const SizedBox(height: 24),

                  // Divider
                  _buildDivider(),

                  const SizedBox(height: 24),

                  // Social Login (Optional)
                  _buildSocialLogin(),

                  const SizedBox(height: 32),

                  // Sign Up Link
                  _buildSignUpLink(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          AppStrings.login,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Inicia sesión con tu email institucional',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        CustomTextField(
          label: AppStrings.email,
          hint: 'tu.email@universidad.edu',
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.email_outlined,
          validator: Validators.validateEmail,
          onSubmitted: (_) => _passwordFocusNode.requestFocus(),
        ),
        const SizedBox(height: 20),
        BlocBuilder<UiCubit, UiState>(
          builder: (context, uiState) {
            return CustomTextField(
              label: AppStrings.password,
              hint: 'Ingresa tu contraseña',
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: !uiState.isPasswordVisible,
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.lock_outline,
              suffixIcon: uiState.isPasswordVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixTap: () =>
                  context.read<UiCubit>().togglePasswordVisibility(),
              validator: Validators.validatePassword,
              onSubmitted: (_) => _handleLogin(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _handleForgotPassword,
        child: const Text(
          AppStrings.forgotPassword,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return CustomButton(
          text: AppStrings.login,
          onPressed: isLoading ? null : _handleLogin,
          isLoading: isLoading,
          width: double.infinity,
          height: 56,
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.borderLight)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.or,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.borderLight)),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        CustomButton(
          text: '${AppStrings.continueWith} Google',
          onPressed: _handleGoogleLogin,
          type: ButtonType.outline,
          width: double.infinity,
          height: 56,
          icon: Icons.g_mobiledata,
        ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.dontHaveAccount,
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: _navigateToRegister,
          child: const Text(
            AppStrings.register,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await context.read<AuthCubit>().login(
            email: _emailController.text,
            password: _passwordController.text,
          );
      // Navigation will be handled by BlocListener
    }
  }

  void _handleForgotPassword() {
    // TODO: Implementar recuperación de contraseña
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad en desarrollo'),
      ),
    );
  }

  void _handleGoogleLogin() {
    // TODO: Implementar login con Google
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad en desarrollo'),
      ),
    );
  }

  void _navigateToRegister() {
    context.go(AppRouter.register);
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Login exitoso!'),
        backgroundColor: AppColors.success,
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

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}