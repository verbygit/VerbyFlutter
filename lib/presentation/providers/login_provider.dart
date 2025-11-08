import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/core/date_time_extension.dart';
import 'package:verby_flutter/data/data_source/local/shared_preference_helper.dart';
import 'package:verby_flutter/data/models/local/employee_action_state.dart';
import 'package:verby_flutter/data/models/local/employee_performs_state.dart';
import 'package:verby_flutter/data/models/remote/device_response.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/data/models/remote/last_record.dart';
import 'package:verby_flutter/data/models/remote/login_response_model.dart';
import 'package:verby_flutter/data/models/remote/record_response.dart';
import 'package:verby_flutter/domain/entities/action.dart';
import 'package:verby_flutter/domain/entities/perform.dart';
import 'package:verby_flutter/domain/entities/states/login_state.dart';
import 'package:verby_flutter/domain/use_cases/auth/get_device_info_use_case.dart';
import 'package:verby_flutter/domain/use_cases/plan/get_plan_use_case.dart';
import 'package:verby_flutter/domain/use_cases/auth/login_use_case.dart';
import 'package:verby_flutter/domain/use_cases/employee/get_employee_use_case.dart';
import 'package:verby_flutter/domain/use_cases/employee/get_local_employee_usecase.dart';
import 'package:verby_flutter/domain/use_cases/employee/insert_emp_action_states.dart';
import 'package:verby_flutter/domain/use_cases/employee/insert_employee_perform_states.dart';
import 'package:verby_flutter/domain/use_cases/record/get_record_from_server_use_case.dart';
import 'package:verby_flutter/presentation/providers/shared_pref_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/check_password_usecase.dart';
import 'package:verby_flutter/presentation/providers/usecase/employee/get_local_employee_usecase_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/employee/insert_emp_action_state_usecase.dart';
import 'package:verby_flutter/presentation/providers/usecase/employee/insert_employee_perform_state_usecase.dart';
import 'package:verby_flutter/presentation/providers/usecase/employee/save_employee_locally_usecase.dart';
import 'package:verby_flutter/presentation/providers/usecase/get_device_info_use_case_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/plan/get_plan_use_case_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/record/get_record_use_case_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/login_use_case_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/plan/insert_plans_usecase_provider.dart';
import '../../data/models/local/plan.dart';
import '../../domain/use_cases/auth/check_password_use_case.dart';
import '../../domain/use_cases/plan/insert_plans_use_case.dart';
import 'usecase/employee/get_employee_use_case_provider.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  final LoginUseCase loginUseCase;
  final GetEmployeeUseCase getEmployeeUseCase;
  final GetRecordFromServerUseCase getRecordFromServerUseCase;
  final CheckPassword checkPasswordUseCase;
  final GetLocalEmployeeUseCase getLocalEmployeesUsecase;
  final saveEmployeesLocallyUseCase;
  final SharedPreferencesHelper? sharedPreferencesHelper;
  final InsertEmployeePerformStates insertEmpPerformState;
  final InsertEmpActionStates insertEmpActionState;
  final GetPlanUseCase getPlanUseCase;
  final InsertPlansUseCase insertPlansUseCase;
  final GetDeviceInfoUseCase _getDeviceInfoUseCase;

  LoginNotifier(
    this.loginUseCase,
    this.getEmployeeUseCase,
    this.getRecordFromServerUseCase,
    this.saveEmployeesLocallyUseCase,
    this.checkPasswordUseCase,
    this.getLocalEmployeesUsecase,
    this.sharedPreferencesHelper,
    this.insertEmpPerformState,
    this.insertEmpActionState,
    this.getPlanUseCase,
    this.insertPlansUseCase,
    this._getDeviceInfoUseCase,
  ) : super(LoginState()) {
    _getUser();
    _getEmployees();
  }

  void _getUser() {
    final user = sharedPreferencesHelper?.getUser();
    if (user != null) {
      state = state.copyWith(userModel: user);
    }
  }

  void _getEmployees() async {
    final employees = await getLocalEmployeesUsecase.call();
    employees.fold(
      (onError) {
        if (kDebugMode) {
          print(onError);
        }
      },
      (onSuccessResponse) {
        state = state.copyWith(employees: onSuccessResponse);
      },
    );
  }

  Employee? getEmployeeById(int id) {
    final employees = state.employees;
    if (employees != null) {
      for (var employee in employees) {
        if (employee.id == id) {
          return employee;
        }
      }
    }
    return null;
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    final result = await loginUseCase.call(email, password);

    await result.fold(
      (onError) async {
        if (kDebugMode) {
          print("onError in provider ${onError.message}");
        }
        state = state.copyWith(isLoading: false, error: onError.message);
      },
      (loginResponse) async {
        await saveAuthToken(loginResponse.token ?? "");

        // Run getEmployeesAndSave and getDeviceInfo in parallel using Future.wait
        final results = await Future.wait([
          getEmployeesAndSave(loginResponse.deviceId ?? -1),
          getDeviceInfo(loginResponse.deviceId.toString()),
        ]);

        // Extract results from Future.wait
        final employeeResult = results[0] as bool;
        final deviceData = results[1] as DeviceResponse?;

        if (employeeResult && deviceData != null) {
          await saveLoginResponse(loginResponse, password, deviceData);

          state = state.copyWith(
            isSignedIn: true,
            isLoading: false,
            loginResponseModel: loginResponse,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            error: "Something went wrong",
          );
        }
      },
    );
  }

  Future<DeviceResponse?> getDeviceInfo(String deviceID) async {
    final deviceResult = await _getDeviceInfoUseCase.call(deviceID);
    return deviceResult.fold(
      (onError) async {
        return null;
      },
      (onData) async {
        return onData;
      },
    );
  }

  Future<void> checkPassword(String password) async {
    if (sharedPreferencesHelper == null) {
      state = state.copyWith(
        isLoading: false,
        error: "SharedPreferences not available",
      );
      return;
    }

    if (state.isInternetConnected) {
      final deviceID = sharedPreferencesHelper?.getInt(
        SharedPreferencesHelper.DEVICE_ID_KEY ?? '',
      );
      if (deviceID != null) {
        state = state.copyWith(isLoading: true);
        final result = await checkPasswordUseCase.call(
          deviceID.toString(),
          password,
        );
        result.fold(
          (onError) {
            state = state.copyWith(isLoading: false, error: onError.message);
          },
          (onData) {
            if (onData) {
              state = state.copyWith(
                isLoading: false,
                isPasswordCorrect: onData,
              );
            } else {
              state = state.copyWith(
                isLoading: false,
                error: "incorrect_password".tr(),
              );
            }
          },
        );
      }
    } else {
      final savedPassword = await sharedPreferencesHelper?.getPassword();
      if (savedPassword == null) {
        state = state.copyWith(
          isLoading: false,
          error: "incorrect_password".tr(),
        );
      } else {
        if (savedPassword == password) {
          state = state.copyWith(isLoading: false, isPasswordCorrect: true);
        } else {
          state = state.copyWith(
            isLoading: false,
            error: "incorrect_password".tr(),
          );
        }
      }
    }
  }

  Future<void> saveAuthToken(String token) async {
    await sharedPreferencesHelper?.setToken(token);
  }

  Future<void> saveLoginResponse(
    LoginResponseModel loginResponseModel,
    String password,
    DeviceResponse deviceResponse,
  ) async {
    sharedPreferencesHelper?.saveUser(
      loginResponseModel,
      deviceResponse,
      password,
    );
  }

  Future<void> clearError() async {
    state = state.copyWith(error: "");
  }

  void setMessage(String message) {
    state = state.copyWith(message: message);
  }

  void setErrorMessage(String message) {
    state = state.copyWith(error: message);
  }

  void saveInternetStatus(bool isConnected) {
    state = state.copyWith(isInternetConnected: isConnected);
  }

  Future<void> resetLogin() async {
    state = state.copyWith(isLoading: false, isSignedIn: false, error: null);
  }

  Future<bool> getEmployeesAndSave(int deviceID) async {
    final employeeResult = await getEmployeeUseCase.call(deviceID);

    return await employeeResult.fold(
      (onError) async {
        if (kDebugMode) {
          print("onError in provider ${onError.message}");
        }
        state = state.copyWith(isLoading: false, error: onError.message);
        return false;
      },
      (onData) async {
        saveEmployeesLocallyUseCase.call(onData.employees ?? []);
        state = state.copyWith(isLoading: false, employees: onData.employees);
        return true;
      },
    );
  }

  Future<bool> getRecordAndSave(List<Employee> employees) async {
    var isSuccessful = true;

    // Map each employee to a Future

    final List<EmployeeActionState> actionStates = [];
    final List<EmployeePerformState> performState = [];
    final futures = employees.map((employee) async {
      final result = await getRecordFromServerUseCase.call(employee.id ?? -1);

      await result.fold(
        (onError) async {
          if (kDebugMode) {
            print("onError in provider ${onError.message}");
          }
          state = state.copyWith(isLoading: false, error: onError.message);
          isSuccessful = false;
        },
        (onData) async {
          if (onData.lastRecords != null && onData.lastRecords!.isNotEmpty) {
            final empActionState = createEmployeeActionState(onData);
            actionStates.add(empActionState);

            if (!empActionState.checkedOut) {
              final empPerformState = createEmployeePerformState(
                onData.lastRecords!.first,
              );
              performState.add(empPerformState);
            }
          }
        },
      );
    }).toList();

    await Future.wait(futures);
    await insertEmpActionState.call(actionStates);
    await insertEmpPerformState.call(performState);

    return isSuccessful;
  }

  Future<bool> getPlansAndSave(List<Employee> employees, int deviceId) async {
    var isSuccessful = true;

    final List<Plan> plans = [];

    final futures = employees.map((employee) async {
      final result = await getPlanUseCase.call(
        deviceId.toString(),
        employee.id ?? -1,
      );

      await result.fold(
        (onError) async {
          if (kDebugMode) {
            print("onError in provider ${onError.message}");
          }
          state = state.copyWith(isLoading: false, error: onError.message);
          isSuccessful = false;
        },
        (onData) async {
          if (kDebugMode) {
            print("Plan for ${employee.id}======> $onData");
          }
          plans.add(Plan(employeeId: employee.id ?? -1, time: onData));
        },
      );
    }).toList();

    await Future.wait(futures);
    await insertPlansUseCase.call(plans);

    return isSuccessful;
  }

  EmployeePerformState createEmployeePerformState(LastRecords lastRecord) {
    var employeePerformState = EmployeePerformState(
      id: lastRecord.employeeId ?? -1,
    );

    switch (Perform.getPerform(lastRecord.perform ?? -1)) {
      case Perform.BURO:
        {
          employeePerformState.isBuro = true;
        }
        break;
      case Perform.MAINTENANCE:
        {
          employeePerformState.isMaintenance = true;
        }
        break;
      case Perform.ROOMCLEANING:
        {
          employeePerformState.isRoomCleaning = true;
        }
        break;
      case Perform.ROOMCONTROL:
        {
          employeePerformState.isRoomControl = true;
        }
        break;
      case Perform.STEWARDING:
        {
          employeePerformState.isStewarding = true;
        }
        break;
      case Perform.ERROR:
        break;
    }
    return employeePerformState;
  }

  EmployeeActionState createEmployeeActionState(RecordResponse recordResponse) {
    LastRecords lastRecord = recordResponse.lastRecords!.first;
    String? latestActionTime = lastRecord.time?.toLocalTime() ?? "";
    if (lastRecord.action == Action.CHECKIN.getActionValue()) {}

    EmployeeActionState employeeActionState = EmployeeActionState(
      id: lastRecord.employeeId ?? -1,
      lastActionTime: latestActionTime,
    );
    switch (Action.getAction(lastRecord.action ?? -1)) {
      case Action.CHECKIN:
        {
          employeeActionState.checkedIn = false;
          employeeActionState.pausedOut = false;
          employeeActionState.checkInTime = latestActionTime ?? "";
        }
        break;
      case Action.PAUSEIN:
        {
          employeeActionState.pausedIn = false;
          employeeActionState.checkedIn = false;
          employeeActionState.checkedOut = false;
          employeeActionState.hadAPause = true;
          for (var record in recordResponse.lastRecords!) {
            if (record.action == Action.CHECKIN.getActionValue()) {
              employeeActionState.checkInTime =
                  record.time?.toLocalTime() ?? "";
            }
          }
        }
        break;
      case Action.PAUSEOUT:
        {
          employeeActionState.pausedOut = false;
          employeeActionState.checkedIn = false;
          for (var record in recordResponse.lastRecords!) {
            if (record.action == Action.CHECKIN.getActionValue()) {
              employeeActionState.checkInTime =
                  record.time?.toLocalTime() ?? "";
            }
          }
        }
        break;
      case Action.CHECKOUT:
        {
          employeeActionState.pausedOut = false;
          employeeActionState.pausedIn = false;
          employeeActionState.checkedOut = false;
        }
        break;
      case Action.ERROR:
    }
    return employeeActionState;
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final loginUseCase = ref.read(loginUseCaseProvider);
  final checkPasswordUseCase = ref.read(checkPasswordUseCaseProvider);
  final getEmployeeUseCase = ref.read(getEmployeeUseCaseProvider);
  final saveEmployeesLocallyUseCase = ref.read(saveEmployeesLocallyProvider);
  final getLocalEmployeesUsecase = ref.read(getLocalEmployeeUseCaseProvider);
  final getRecordUseCase = ref.read(getRecordUseCaseProvider);
  final insertEmpPerformState = ref.read(
    insertEmployeePerformStatesUseCaseProvider,
  );
  final insertEmpActionState = ref.read(insertEmpActionStatesUserCaseProvider);
  final getPlanUseCase = ref.read(getPlanUseCaseProvider);
  final insertPlanUseCase = ref.read(insertPlansUseCaseProvider);
  final getDeviceInfoUseCase = ref.read(getDeviceInfoUseCaseProvider);
  // Handle SharedPreferences asynchronously to avoid exceptions
  final sharedPrefsAsync = ref.watch(sharedPreferencesProvider);
  final sharedPreferencesHelper = sharedPrefsAsync.when(
    data: (helper) => helper,
    loading: () => null,
    error: (_, __) => null,
  );

  return LoginNotifier(
    loginUseCase,
    getEmployeeUseCase,
    getRecordUseCase,
    saveEmployeesLocallyUseCase,
    checkPasswordUseCase,
    getLocalEmployeesUsecase,
    sharedPreferencesHelper,
    insertEmpPerformState,
    insertEmpActionState,
    getPlanUseCase,
    insertPlanUseCase,
    getDeviceInfoUseCase,
  );
});
