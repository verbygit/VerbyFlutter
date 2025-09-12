import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/data/models/remote/login_response_model.dart';
import 'package:verby_flutter/data/models/remote/user_model.dart';

class LoginState {
  final bool isLoading;
  final String? error;
  final String? message;
  final bool isSignedIn;
  final bool isPasswordCorrect;
  final bool isInternetConnected;
  final LoginResponseModel? loginResponseModel;
  final UserModel? userModel;
  final List<Employee>? employees;

  LoginState({
    this.isLoading = false,
    this.error = "",
    this.message = "",
    this.isSignedIn = false,
    this.isPasswordCorrect = false,
    this.isInternetConnected = false,
    this.loginResponseModel,
    this.userModel,
    this.employees,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isSignedIn,
    bool? isInternetConnected,
    bool? isPasswordCorrect,
    String? error,
    String? message,
    LoginResponseModel? loginResponseModel,
    UserModel? userModel,
    List<Employee>? employees,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      isInternetConnected: isInternetConnected ?? this.isInternetConnected,
      error: error ?? this.error,
      message: message ?? this.message,
      loginResponseModel: loginResponseModel ?? this.loginResponseModel,
      isPasswordCorrect: isPasswordCorrect ?? this.isPasswordCorrect,
      userModel: userModel ?? this.userModel,
      employees: employees ?? this.employees,
    );
  }
}
