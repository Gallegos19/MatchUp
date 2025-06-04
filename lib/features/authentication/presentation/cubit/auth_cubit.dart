// lib/features/authentication/presentation/cubit/auth_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

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
    // We don't emit a new state for UI-only changes
    // Instead, we can use a separate stream or callback
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
      (user) {
        emit(AuthAuthenticated(user: user));
        return true;
      },
    );
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(AuthLoading());

    final result = await registerUser(RegisterParams(
      email: email.trim(),
      password: password,
      name: name.trim(),
    ));

    return result.fold(
      (failure) {
        emit(AuthError(message: _getFailureMessage(failure)));
        return false;
      },
      (user) {
        emit(AuthAuthenticated(user: user));
        return true;
      },
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());
    
    // TODO: Call logout use case when implemented
    // final result = await logoutUser(NoParams());
    
    // For now, just emit unauthenticated
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call
    emit(AuthUnauthenticated());
  }

  void clearError() {
    if (state is AuthError) {
      emit(AuthInitial());
    }
  }

  // Check authentication status on app start
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    
    // TODO: Implement check if user is logged in
    // final result = await getCurrentUser(NoParams());
    
    // For now, just emit unauthenticated
    await Future.delayed(const Duration(milliseconds: 1000)); // Simulate check
    emit(AuthUnauthenticated());
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