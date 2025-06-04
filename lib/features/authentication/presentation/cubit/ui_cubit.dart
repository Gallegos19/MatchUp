// lib/features/authentication/presentation/cubit/ui_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// State for UI-specific changes (like password visibility)
class UiState extends Equatable {
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;

  const UiState({
    this.isPasswordVisible = false,
    this.isConfirmPasswordVisible = false,
  });

  UiState copyWith({
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
  }) {
    return UiState(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible: isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
    );
  }

  @override
  List<Object> get props => [isPasswordVisible, isConfirmPasswordVisible];
}

// Cubit for UI state management
class UiCubit extends Cubit<UiState> {
  UiCubit() : super(const UiState());

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void toggleConfirmPasswordVisibility() {
    emit(state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible));
  }

  void resetState() {
    emit(const UiState());
  }
}