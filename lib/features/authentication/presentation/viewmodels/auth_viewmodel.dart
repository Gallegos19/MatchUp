// lib/features/authentication/presentation/viewmodels/auth_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final LoginUser loginUser;
  final RegisterUser registerUser;

  AuthViewModel({
    required this.loginUser,
    required this.registerUser,
  });

  // State management
  AuthState _state = AuthState.initial;
  User? _currentUser;
  String? _errorMessage;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Getters
  AuthState get state => _state;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _state == AuthState.authenticated;

  // Methods
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.initial;
    }
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoadingState();

    final result = await loginUser(LoginParams(
      email: email.trim(),
      password: password,
    ));

    return result.fold(
      (failure) {
        _setErrorState(_getFailureMessage(failure));
        return false;
      },
      (user) {
        _setAuthenticatedState(user);
        return true;
      },
    );
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoadingState();

    final result = await registerUser(RegisterParams(
      email: email.trim(),
      password: password,
      name: name.trim(),
    ));

    return result.fold(
      (failure) {
        _setErrorState(_getFailureMessage(failure));
        return false;
      },
      (user) {
        _setAuthenticatedState(user);
        return true;
      },
    );
  }

  Future<void> logout() async {
    _currentUser = null;
    _state = AuthState.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoadingState() {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setAuthenticatedState(User user) {
    _state = AuthState.authenticated;
    _currentUser = user;
    _errorMessage = null;
    notifyListeners();
  }

  void _setErrorState(String message) {
    _state = AuthState.error;
    _errorMessage = message;
    notifyListeners();
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

  @override
  void dispose() {
    super.dispose();
  }
}