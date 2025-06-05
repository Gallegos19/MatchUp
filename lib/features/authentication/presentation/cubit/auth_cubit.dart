import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../../../di/injection_container.dart' as di;

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

// NEW: State specifically for successful registration
class AuthRegistrationSuccess extends AuthState {
  final String message;

  const AuthRegistrationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

// Cubit
class AuthCubit extends Cubit<AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;

  AuthCubit({
    required this.loginUser,
    required this.registerUser,
  }) : super(AuthInitial());

  // UI State management
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Getters
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  bool get isLoading => state is AuthLoading;
  bool get isAuthenticated => state is AuthAuthenticated;
  User? get currentUser => state is AuthAuthenticated 
      ? (state as AuthAuthenticated).user 
      : null;

  // Password visibility methods
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
  }

  // Authentication methods
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    final result = await loginUser(LoginParams(
      email: email.trim(),
      password: password,
    ));

    return result.fold(
      (failure) {
        emit(AuthError(message: _getFailureMessage(failure)));
        return false;
      },
      (user) async {
        // Store token if available
        if (user is AuthenticatedUser && user.token != null) {
          await di.updateStoredToken(user.token!);
        }
        emit(AuthAuthenticated(user: user));
        return true;
      },
    );
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String career,
    required int semester,
    required String campus,
  }) async {
    emit(AuthLoading());

    final result = await registerUser(RegisterParams(
      email: email.trim(),
      password: password,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      dateOfBirth: dateOfBirth,
      career: career.trim(),
      semester: semester,
      campus: campus.trim(),
    ));

    return result.fold(
      (failure) {
        emit(AuthError(message: _getFailureMessage(failure)));
        return false;
      },
      (user) async {
        // FIXED: Don't authenticate user immediately after registration
        // Instead, emit a success state that indicates registration was successful
        // but user needs to login
        
        // Don't store token or authenticate user automatically
        // Let them login manually for security reasons
        
        emit(AuthRegistrationSuccess(
          message: 'Registro exitoso. Por favor, inicia sesión con tus credenciales.',
        ));
        return true;
      },
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());
    
    try {
      // Clear stored token
      await di.clearAuthData();

      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Error al cerrar sesión: $e'));
    }
  }

  void clearError() {
    if (state is AuthError) {
      emit(AuthInitial());
    }
  }

  void clearRegistrationSuccess() {
    if (state is AuthRegistrationSuccess) {
      emit(AuthInitial());
    }
  }

  // Check authentication status on app start
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    
    try {
      // Check if we have a stored token
      final token = await di.getStoredToken();
      
      if (token != null && token.isNotEmpty) {
        // TODO: Validate token with server and get current user
        // For now, we'll assume the token is valid
        // final result = await getCurrentUser(NoParams());
        
        // Simulate token validation
        await Future.delayed(const Duration(milliseconds: 500));
        
        // For now, just emit unauthenticated if no valid user data
        emit(AuthUnauthenticated());
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  String _getFailureMessage(Failure failure) {
    switch (failure.runtimeType) {
      case AuthenticationFailure:
        return 'Credenciales incorrectas. Verifica tu email y contraseña';
      case NetworkFailure:
        return 'Error de conexión. Verifica tu internet';
      case ServerFailure:
        return 'Error del servidor. Intenta más tarde';
      case ValidationFailure:
        return failure.message;
      case UserAlreadyExistsFailure:
        return 'Ya existe una cuenta con este email';
      case UserNotFoundFailure:
        return 'No se encontró una cuenta con este email';
      case TimeoutFailure:
        return 'Tiempo de espera agotado. Intenta nuevamente';
      case UnauthorizedFailure:
        return 'No tienes autorización para realizar esta acción';
      case CacheFailure:
        return 'Error al guardar datos localmente';
      default:
        return failure.message.isNotEmpty 
            ? failure.message 
            : 'Ha ocurrido un error inesperado';
    }
  }
}

// Helper class for authenticated user with token
class AuthenticatedUser extends User {
  final String? token;

  const AuthenticatedUser({
    required super.id,
    required super.email,
    required super.name,
    required super.age,
    required super.career,
    required super.semester,
    required super.campus,
    required super.bio,
    required super.interests,
    required super.photoUrls,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
    required super.isProfileComplete,
    this.token,
  });

  factory AuthenticatedUser.fromUser(User user, String? token) {
    return AuthenticatedUser(
      id: user.id,
      email: user.email,
      name: user.name,
      age: user.age,
      career: user.career,
      semester: user.semester,
      campus: user.campus,
      bio: user.bio,
      interests: user.interests,
      photoUrls: user.photoUrls,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isActive: user.isActive,
      isProfileComplete: user.isProfileComplete,
      token: token,
    );
  }
}