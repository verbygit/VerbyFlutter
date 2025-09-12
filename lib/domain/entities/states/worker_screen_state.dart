import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/data/models/remote/user_model.dart';

class WorkerScreenState {
  final String errorMessage;
  final bool isInternetConnected;
  final UserModel? userModel;
  final List<Employee>? employees;

  WorkerScreenState({
    this.isInternetConnected = false,
    this.errorMessage = "",
    this.userModel,
    this.employees,
  });

  WorkerScreenState copyWith({
    bool? isInternetConnected,
    String? errorMessage,
    UserModel? userModel,
    List<Employee>? employees
  }) {
    return WorkerScreenState(
      isInternetConnected: isInternetConnected ?? this.isInternetConnected,
      errorMessage: errorMessage ?? this.errorMessage,
      userModel: userModel ?? this.userModel,
      employees: employees ?? this.employees,
    );
  }
}
