// lib/features/authentication/presentation/pages/register_page.dart - FIXED
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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _careerController = TextEditingController();
  
  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _dateOfBirthFocusNode = FocusNode();
  final _careerFocusNode = FocusNode();

  int _selectedSemester = 1;
  String _selectedCampus = 'Tuxtla Gutiérrez';

  final List<String> _campusOptions = [
    'Tuxtla Gutiérrez',
    'Suchiapa',
    'Tapachula',
    'Comitán',
    'San Cristóbal',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dateOfBirthController.dispose();
    _careerController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _dateOfBirthFocusNode.dispose();
    _careerFocusNode.dispose();
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
                // FIXED: Handle the new AuthRegistrationSuccess state
                if (state is AuthRegistrationSuccess) {
                  _showSuccessSnackBar(state.message);
                  // Navigate to login page instead of home
                  context.go(AppRouter.login);
                  // Clear the registration success state
                  context.read<AuthCubit>().clearRegistrationSuccess();
                } else if (state is AuthAuthenticated) {
                  // This should not happen after registration anymore
                  // But just in case, navigate to home
                  context.go(AppRouter.home);
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
        // First Name Field
        CustomTextField(
          label: 'Nombre',
          hint: 'Ingresa tu nombre',
          controller: _firstNameController,
          focusNode: _firstNameFocusNode,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.person_outline,
          validator: Validators.validateName,
          onSubmitted: (_) => _lastNameFocusNode.requestFocus(),
        ),
        
        const SizedBox(height: 20),

        // Last Name Field
        CustomTextField(
          label: 'Apellidos',
          hint: 'Ingresa tus apellidos',
          controller: _lastNameController,
          focusNode: _lastNameFocusNode,
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
          onSubmitted: (_) => _dateOfBirthFocusNode.requestFocus(),
        ),

        const SizedBox(height: 20),

        // Date of Birth Field
        GestureDetector(
          onTap: _selectDate,
          child: AbsorbPointer(
            child: CustomTextField(
              label: 'Fecha de Nacimiento',
              hint: 'DD/MM/AAAA',
              controller: _dateOfBirthController,
              focusNode: _dateOfBirthFocusNode,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.calendar_today_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La fecha de nacimiento es requerida';
                }
                return null;
              },
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Career Field
        CustomTextField(
          label: 'Carrera',
          hint: 'Ej: Ingeniería en Sistemas',
          controller: _careerController,
          focusNode: _careerFocusNode,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.school_outlined,
          validator: Validators.validateCareer,
          onSubmitted: (_) => _passwordFocusNode.requestFocus(),
        ),

        const SizedBox(height: 20),

        // Semester Dropdown
        _buildSemesterDropdown(),

        const SizedBox(height: 20),

        // Campus Dropdown
        _buildCampusDropdown(),
        
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

  Widget _buildSemesterDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Semestre',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderLight,
              width: 2,
            ),
          ),
          child: DropdownButtonFormField<int>(
            value: _selectedSemester,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(Icons.school, color: AppColors.textHint),
            ),
            items: List.generate(12, (index) => index + 1)
                .map((semester) => DropdownMenuItem(
                      value: semester,
                      child: Text('$semester° Semestre'),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedSemester = value ?? 1;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCampusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Campus',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderLight,
              width: 2,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCampus,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(Icons.location_on, color: AppColors.textHint),
            ),
            items: _campusOptions
                .map((campus) => DropdownMenuItem(
                      value: campus,
                      child: Text(campus),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCampus = value ?? _campusOptions.first;
              });
            },
          ),
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)), // At least 16 years old
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = 
            '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  String _formatDateForApi(String displayDate) {
    // Convert DD/MM/YYYY to YYYY-MM-DD
    final parts = displayDate.split('/');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return displayDate;
  }

  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await context.read<AuthCubit>().register(
        email: _emailController.text,
        password: _passwordController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        dateOfBirth: _formatDateForApi(_dateOfBirthController.text),
        career: _careerController.text,
        semester: _selectedSemester,
        campus: _selectedCampus,
      );

      // The navigation will be handled by the BlocListener
      // based on the state emitted from the AuthCubit
    }
  }

  void _navigateToLogin() {
    context.go(AppRouter.login);
  }

  void _showSuccessSnackBar([String? customMessage]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(customMessage ?? '¡Registro exitoso!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4), // Show longer for custom message
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