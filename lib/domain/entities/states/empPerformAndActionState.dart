import 'package:verby_flutter/data/models/remote/user_model.dart';

import '../../../data/models/local/employee_action_state.dart';
import '../../../data/models/local/employee_performs_state.dart';

class EmployeePerformAndActionState {
  final bool isLoading;
  bool isInternetConnected;
  final EmployeePerformState? currentEmpPerformState;
  final EmployeeActionState? currentEmpActionState;
  final String errorMessage;
  final String message;
  final UserModel? user;

  EmployeePerformAndActionState({
    this.isLoading = false,
     this.isInternetConnected = false,

    this.currentEmpActionState,
    this.currentEmpPerformState,
    this.errorMessage = "",
    this.message = "",
    this.user,
  });

  EmployeePerformAndActionState copyWith({
    bool? isLoading,
    bool? isInternetConnected,
    EmployeePerformState? currentEmpPerformState,
    EmployeeActionState? currentEmpActionState,
    String? errorMessage,
    String? message,
    UserModel? user
  }) {
    return EmployeePerformAndActionState(
      isLoading: isLoading ?? this.isLoading,
      isInternetConnected: isInternetConnected ?? this.isInternetConnected,

      currentEmpPerformState:
          currentEmpPerformState ?? this.currentEmpPerformState,
      currentEmpActionState:
          currentEmpActionState ?? this.currentEmpActionState,
      errorMessage: errorMessage ?? this.errorMessage,
      message: message ?? this.message,
      user: user ?? this.user,
    );
  }
}
