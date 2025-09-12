import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/core/date_time_extension.dart';
import 'package:verby_flutter/data/mappers/data_mappers.dart';
import 'package:verby_flutter/data/models/local/depa_restant_model.dart';
import 'package:verby_flutter/data/models/remote/calender/calender_response.dart';
import 'package:verby_flutter/data/models/remote/user_model.dart';
import 'package:verby_flutter/domain/use_cases/depa_restant/get_depas_restants_use_case.dart';
import 'package:verby_flutter/domain/use_cases/depa_restant/insert_depas_restants_use_case.dart';
import 'package:verby_flutter/domain/use_cases/plan/get_plan_use_case.dart';
import 'package:verby_flutter/domain/use_cases/employee/get_local_employee_usecase.dart';
import 'package:verby_flutter/domain/use_cases/employee/insert_emp_action_states.dart';
import 'package:verby_flutter/domain/use_cases/employee/insert_employee_perform_states.dart';
import 'package:verby_flutter/domain/use_cases/plan/insert_plans_use_case.dart';
import 'package:verby_flutter/domain/use_cases/record/get_record_from_server_use_case.dart';
import 'package:verby_flutter/presentation/providers/usecase/depa_restant/get_depas_restants_use_case_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/depa_restant/insert_depas_restants_usecase_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/employee/get_local_employee_usecase_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/employee/insert_emp_action_state_usecase.dart';
import 'package:verby_flutter/presentation/providers/usecase/employee/insert_employee_perform_state_usecase.dart';
import 'package:verby_flutter/presentation/providers/usecase/plan/insert_plans_usecase_provider.dart';
import '../../data/models/local/employee_action_state.dart';
import '../../data/models/local/employee_performs_state.dart';
import '../../data/models/local/plan.dart';
import '../../data/models/remote/employee.dart';
import '../../data/models/remote/last_record.dart';
import '../../data/models/remote/record_response.dart';
import '../../domain/core/connectivity_helper.dart';
import '../../domain/core/failure.dart';
import '../../domain/entities/action.dart';
import '../../domain/entities/perform.dart';
import '../../domain/entities/room_status.dart';
import '../../domain/entities/states/worker_screen_state.dart';
import 'usecase/plan/get_plan_use_case_provider.dart';
import 'usecase/record/get_record_use_case_provider.dart';

class WorkerScreenProviderNotifier extends StateNotifier<WorkerScreenState> {
  final GetRecordFromServerUseCase _getRecordFromServerUseCase;
  final InsertEmployeePerformStates _insertEmpPerformStateUseCase;
  final InsertEmpActionStates _insertEmpActionState;
  final GetPlanUseCase _getPlanUseCase;
  final InsertPlansUseCase _insertPlansUseCase;
  final GetLocalEmployeeUseCase _getLocalEmpUseCase;
  final GetDepaRestantsUseCase _getDepaRestantsUseCase;
  final InsertDepaRestantsUseCase _insertDepaRestantsUseCase;

  WorkerScreenProviderNotifier(
    this._getRecordFromServerUseCase,
    this._insertEmpPerformStateUseCase,
    this._insertEmpActionState,
    this._getPlanUseCase,
    this._insertPlansUseCase,
    this._getLocalEmpUseCase,
    this._getDepaRestantsUseCase,
    this._insertDepaRestantsUseCase,
  ) : super(WorkerScreenState()) {
    getEmployees();
  }

  listenToInternetStatus() {
    ConnectivityHelper().onStatusChange.listen((onData) {
      if (onData == ConnectivityStatus.online) {
        saveInternetStatus(true);
      } else {
        saveInternetStatus(false);
      }
    });
  }

  void getEmployees() async {
    final employees = await _getLocalEmpUseCase.call();
    await employees.fold(
      (onError) {
        if (kDebugMode) {
          print(onError);
        }
      },
      (onSuccessResponse) async {
        state = state.copyWith(employees: onSuccessResponse);
      },
    );
  }

  void saveUser(UserModel user) {
    state = state.copyWith(userModel: user);
  }

  void saveInternetStatus(bool isConnected) {
    state = state.copyWith(isInternetConnected: isConnected);
  }

  Future<void> getDepaRestantAndEmployeesStates() async {
    final userModel = state.userModel;
    final employees = state.employees;

    if (employees == null || userModel?.deviceID == null) {
      state = state.copyWith(errorMessage: "Invalid input data");
      return;
    }

    final List<EmployeeActionState> actionStates = [];
    final List<EmployeePerformState> performStates = [];
    final List<DepaRestantModel> depaRestants = [];
    final List<String> errors = [];

    final futures = employees.map((employee) async {
      final empId = employee.id ?? -1;

      final resultDepaAndRestant = _getDepaRestantsUseCase.call(
        userModel?.deviceID.toString() ?? "",
        empId,
      );

      final resultRecords = _getRecordFromServerUseCase.call(empId);

      final results = await Future.wait([resultDepaAndRestant, resultRecords]);

      // Handle Records result
      final recordsResult = results[1] as Either<Failure, RecordResponse>;
      await recordsResult.fold(
        (onError) async {
          errors.add(onError.message);
        },
        (onData) {
          final lastRecords = onData.lastRecords;
          if (lastRecords != null && lastRecords.isNotEmpty) {
            final empActionState = createEmployeeActionState(onData);
            actionStates.add(empActionState);

            if (Action.getAction(lastRecords.first.action ?? -1) !=
                Action.CHECKOUT) {
              final empPerformState = createEmployeePerformState(
                lastRecords.first,
              );
              performStates.add(empPerformState);
            }
          }
        },
      );

      // Handle DepaRestant result
      final depaResult = results[0] as Either<Failure, CalenderResponse>;
      await depaResult.fold(
        (onError) async {
          errors.add(onError.message);
        },
        (onData) {
          final depaList = onData.depa
              ?.map(
                (e) => e.toDepaRestantModel(
                  empId.toString(),
                  true,
                  RoomStatus.CLEANED.getRoomStatusValue(),
                ),
              )
              .toList();
          final restantList = onData.restant
              ?.map(
                (e) => e.toDepaRestantModel(
                  empId.toString(),
                  false,
                  RoomStatus.CLEANED.getRoomStatusValue(),
                ),
              )
              .toList();

          if (depaList != null) depaRestants.addAll(depaList);
          if (restantList != null) depaRestants.addAll(restantList);
        },
      );
    }).toList();

    await Future.wait(futures);

    if (depaRestants.isNotEmpty) {
      await _insertDepaRestantsUseCase.call(depaRestants);
    }

    if (actionStates.isNotEmpty) {
      await _insertEmpActionState.call(actionStates);
    }

    if (performStates.isNotEmpty) {
      await _insertEmpPerformStateUseCase.call(performStates);
    }

    if (errors.isNotEmpty) {
      state = state.copyWith(errorMessage: errors.join(", "));
    }
  }

  Future<bool> getPlansAndSave(List<Employee> employees, int deviceId) async {
    var isSuccessful = true;

    final List<Plan> plans = [];

    final futures = employees.map((employee) async {
      final result = await _getPlanUseCase.call(
        deviceId.toString(),
        employee.id ?? -1,
      );

      await result.fold(
        (onError) async {
          if (kDebugMode) {
            print("onError in provider ${onError.message}");
          }
          state = state.copyWith(errorMessage: onError.message);
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
    await _insertPlansUseCase.call(plans);

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
}

final workerScreenProvider =
    StateNotifierProvider<WorkerScreenProviderNotifier, WorkerScreenState>((
      ref,
    ) {
      final getRecordUseCase = ref.read(getRecordUseCaseProvider);
      final insertEmpPerformState = ref.read(
        insertEmployeePerformStatesUseCaseProvider,
      );
      final insertEmpActionState = ref.read(
        insertEmpActionStatesUserCaseProvider,
      );
      final getPlanUseCase = ref.read(getPlanUseCaseProvider);
      final getDepaRestantUseCase = ref.read(getDepaRestantsUseCaseProvider);
      final insertPlanUseCase = ref.read(insertPlansUseCaseProvider);
      final getLocalEmpUseCase = ref.read(getLocalEmployeeUseCaseProvider);
      final insertDepaRestantUseCase = ref.read(
        insertDepaRestantsUseCaseProvider,
      );

      return WorkerScreenProviderNotifier(
        getRecordUseCase,
        insertEmpPerformState,
        insertEmpActionState,
        getPlanUseCase,
        insertPlanUseCase,
        getLocalEmpUseCase,
        getDepaRestantUseCase,
        insertDepaRestantUseCase,
      );
    });
