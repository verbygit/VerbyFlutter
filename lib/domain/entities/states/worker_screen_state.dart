import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/data/models/remote/user_model.dart';

import '../../../data/data_source/local/shared_preference_helper.dart';

class WorkerScreenState {
  final String errorMessage;
  final String message;
  final bool isInternetConnected;
  final bool isSyncing;
  final bool isFaceIdForAll;
  final bool isFaceForRegisterFace;
  final UserModel? userModel;
  final List<Employee>? employees;
  final SharedPreferencesHelper? sharedPreferencesHelper;

  WorkerScreenState({
    this.isInternetConnected = false,
    this.isSyncing = true,
    this.isFaceIdForAll = false,
    this.isFaceForRegisterFace = false,
    this.errorMessage = "",
    this.message = "",
    this.userModel,
    this.employees,
    this.sharedPreferencesHelper,
  });

  WorkerScreenState copyWith({
    bool? isInternetConnected,
    bool? isSyncing,
    bool? isFaceIdForAll,
    bool? isFaceForRegisterFace,
    String? errorMessage,
    String? message,
    UserModel? userModel,
    List<Employee>? employees,
    SharedPreferencesHelper? sharedPreferencesHelper
  }) {
    return WorkerScreenState(
      isInternetConnected: isInternetConnected ?? this.isInternetConnected,
      isSyncing: isSyncing ?? this.isSyncing,
      isFaceIdForAll: isFaceIdForAll ?? this.isFaceIdForAll,
      isFaceForRegisterFace: isFaceForRegisterFace ?? this.isFaceForRegisterFace,
      errorMessage: errorMessage ?? this.errorMessage,
      message: message ?? this.message,
      userModel: userModel ?? this.userModel,
      employees: employees ?? this.employees,
      sharedPreferencesHelper: sharedPreferencesHelper ?? this.sharedPreferencesHelper,
    );
  }
}
