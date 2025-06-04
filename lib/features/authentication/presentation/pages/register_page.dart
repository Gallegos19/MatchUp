// lib/features/authentication/presentation/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/ui_cubit.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
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
                  context.go(AppRouter.completeProfile);
                } else if (state is AuthError) {
                  _showErrorSnackBar(state.message);
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
                  _buildRegisterForm(),
                  
                  const SizedBox(height: 32),
                  
                  // Register Button
                  _buildRegisterButton(),
                  
                  const SizedBox(height: 24),
                  
                  // Divider
                  _buildDivider(),
                  
                  const SizedBox(height: 24),
                  
                  // Social Register
                  _buildSocialRegister(),
                  
                  const SizedBox(height: 32),
                  
                  // Login Link
                  _buildLoginLink(),
                  
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
          AppStrings.register,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Crea tu cuenta con email institucional',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        // Name Field
        CustomTextField(
          label: AppStrings.name,
          hint: 'Ingresa tu nombre completo',
          controller: _nameController,
          focusNode: _nameFocusNode,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.person_outline,
          validator: Validators.validateName,
          onSubmitted: (_) => _emailFocusNode.requestFocus(),
        ),
        
        const SizedBox(height: 20),
        
        // Email Field
        CustomTextField(
          label: AppStrings.email,
          hint: 'tu.email@universidad.edu',
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.email_outlined,
          validator: Validators.validateInstitutionalEmail,
          onSubmitted: (_) => _passwordFocusNode.requestFocus(),
        ),
        
        const SizedBox(height: 20),
        
        // Password Field
        BlocBuilder<UiCubit, UiState>(
          builder: (context, uiState) {
            return CustomTextField(
              label: AppStrings.password,
              hint: 'Mínimo 6 caracteres',
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: !uiState.isPasswordVisible,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.lock_outline,
              suffixIcon: uiState.isPasswordVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixTap: () => context.read<UiCubit>().togglePasswordVisibility(),
              validator: Validators.validatePassword,
              onSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
            );
          },
        ),
        
        const SizedBox(height: 20),
        
        // Confirm Password Field
        BlocBuilder<UiCubit, UiState>(
          builder: (context, uiState) {
            return CustomTextField(
              label: AppStrings.confirmPassword,
              hint: 'Confirma tu contraseña',
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              obscureText: !uiState.isConfirmPasswordVisible,
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.lock_outline,
              suffixIcon: uiState.isConfirmPasswordVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixTap: () => context.read<UiCubit>().toggleConfirmPasswordVisibility(),
              validator: (value) => Validators.validateConfirmPassword(
                value,
                _passwordController.text,
              ),
              onSubmitted: (_) => _handleRegister(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return CustomButton(
          text: AppStrings.register,
          onPressed: isLoading ? null : _handleRegister,
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

  Widget _buildSocialRegister() {
    return Column(
      children: [
        CustomButton(
          text: '${AppStrings.continueWith} Google',
          onPressed: _handleGoogleRegister,
          type: ButtonType.outline,
          width: double.infinity,
          height: 56,
          icon: Icons.g_mobiledata,
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.alreadyHaveAccount,
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: _navigateToLogin,
          child: const Text(
            AppStrings.signInHere,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      await context.read<AuthCubit>().register(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
      );
    }
  }

  void _handleGoogleRegister() {
    // TODO: Implementar registro con Google
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad en desarrollo'),
      ),
    );
  }

  void _navigateToLogin() {
    context.go(AppRouter.login);
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Registro exitoso!'),
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
}