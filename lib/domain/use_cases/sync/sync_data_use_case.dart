import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:verby_flutter/core/date_time_extension.dart';
import 'package:verby_flutter/data/mappers/data_mappers.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/data/models/remote/user_model.dart';
import 'package:verby_flutter/domain/use_cases/employee/save_employees_locally.dart';
import '../../../data/models/local/depa_restant_model.dart';
import '../../../data/models/local/employee_action_state.dart';
import '../../../data/models/local/employee_performs_state.dart';
import '../../../data/models/local/plan.dart';
import '../../../data/models/remote/calender/calender_response.dart';
import '../../../data/models/remote/last_record.dart';
import '../../../data/models/remote/record_response.dart';
import '../../core/failure.dart';
import '../../entities/action.dart';
import '../../entities/perform.dart';
import '../../entities/room_status.dart';
import '../depa_restant/get_depas_restants_use_case.dart';
import '../depa_restant/insert_depas_restants_use_case.dart';
import '../employee/get_employee_use_case.dart';
import '../employee/get_local_employee_usecase.dart';
import '../employee/insert_emp_action_states.dart';
import '../employee/insert_employee_perform_states.dart';
import '../plan/get_plan_use_case.dart';
import '../plan/insert_plans_use_case.dart';
import '../record/get_record_from_server_use_case.dart';

class SyncDataUseCase {
  final GetRecordFromServerUseCase _getRecordFromServerUseCase;
  final InsertEmployeePerformStates _insertEmpPerformStateUseCase;
  final InsertEmpActionStates _insertEmpActionState;
  final GetPlanUseCase _getPlanUseCase;
  final InsertPlansUseCase _insertPlansUseCase;
  final GetDepaRestantsUseCase _getDepaRestantsUseCase;
  final InsertDepaRestantsUseCase _insertDepaRestantsUseCase;
  final GetEmployeeUseCase _getEmployeeUseCase;
  final SaveEmployeesLocally _saveEmployeesLocallyUserCase;
  final GetLocalEmployeeUseCase _getLocalEmployeeUseCase;

  SyncDataUseCase(
    this._getRecordFromServerUseCase,
    this._insertEmpPerformStateUseCase,
    this._insertEmpActionState,
    this._getPlanUseCase,
    this._insertPlansUseCase,
    this._getDepaRestantsUseCase,
    this._insertDepaRestantsUseCase,
    this._getEmployeeUseCase,
    this._saveEmployeesLocallyUserCase,
    this._getLocalEmployeeUseCase,
  );

  Future<String> syncData(
    UserModel userModel,
    bool shouldGetServerEmployee,
  ) async {
    final employeesResponse = shouldGetServerEmployee
        ? await getEmployeesAndSave(userModel.deviceID ?? -1)
        : await getLocalEmployees();
    if (employeesResponse is String) {
      return employeesResponse;
    }
    List<Employee> employees = employeesResponse as List<Employee>;
    // Run both calls in parallel
    final results = await Future.wait([
      getPlansAndSave(userModel, employees),
      getDepaRestantAndEmployeesStates(userModel, employees),
    ]);
    String planError = results[0];
    String depaRestantAndEmpStateError = results[1];

    if (planError.isNotEmpty || depaRestantAndEmpStateError.isNotEmpty) {
      return " Plan error: $planError , DepaRestantAndEmpState error: $depaRestantAndEmpStateError";
    } else {
      return "";
    }
  }

  Future<String> syncSingleEmpData(UserModel userModel, int empId) async {
    List<String> error = [];

    // Run all three async calls in parallel using Future.wait
    final results = await Future.wait([
      getPlanForEmp(userModel, empId),
      getDepaRestantForEmp(userModel, empId),
      getEmpActionAndPerformState(empId),
    ]);

    // Collect errors from the results
    for (var result in results) {
      if (result.isNotEmpty) {
        error.add(result);
      }
    }

    // Join errors if any, otherwise return empty string
    return error.isNotEmpty ? error.join(", ") : "";
  }

  Future<String> getPlanForEmp(UserModel userModel, int empId) async {
    final planResult = await _getPlanUseCase.call(
      userModel.deviceID.toString(),
      empId,
    );
    return planResult.fold(
      (onError) async {
        return onError.message;
      }, // Return error as a list
      (onData) async {
        final plan = Plan(employeeId: empId, time: onData);
        await _insertPlansUseCase.call([plan]);
        return ""; // Return empty list for success
      },
    );
  }

  Future<String> getEmpActionAndPerformState(int empId) async {
    final resultRecords = await _getRecordFromServerUseCase.call(empId);

    return await resultRecords.fold(
      (onError) async {
        return onError.message;
      },
      (onData) async {
        final lastRecords = onData.lastRecords;
        if (lastRecords != null && lastRecords.isNotEmpty) {
          final empActionState = createEmployeeActionState(onData);
          await _insertEmpActionState.call([empActionState]);

          if (Action.getAction(lastRecords.first.action ?? -1) !=
              Action.CHECKOUT) {
            final empPerformState = createEmployeePerformState(
              lastRecords.first,
            );
            await _insertEmpPerformStateUseCase.call([empPerformState]);
          }
        }
        return "";
      },
    );
  }

  Future<String> getDepaRestantForEmp(UserModel userModel, int empId) async {
    final depaResult = await _getDepaRestantsUseCase.call(
      userModel.deviceID.toString(),
      empId,
    );

    return await depaResult.fold(
      (onError) async {
        return onError.message;
      },
      (onData) async {
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
        final List<DepaRestantModel> depaRestants = [];

        if (depaList != null) depaRestants.addAll(depaList);
        if (restantList != null) depaRestants.addAll(restantList);

        if (depaRestants.isNotEmpty) {
          await _insertDepaRestantsUseCase.call(depaRestants);
        }
        return "";
      },
    );
  }

  Future<dynamic> getLocalEmployees() async {
    final result = await _getLocalEmployeeUseCase.call();

    return await result.fold(
      (onError) async {
        if (kDebugMode) {
          print("onError in provider ${onError}");
        }
        return onError;
      },
      (onData) async {
        if (onData.isNotEmpty) {
          _saveEmployeesLocallyUserCase.call(onData);
          return onData;
        } else {
          return [] as List<Employee>;
        }
      },
    );
  }

  Future<dynamic> getEmployeesAndSave(int deviceID) async {
    final employeeResult = await _getEmployeeUseCase.call(deviceID);

    return await employeeResult.fold(
      (onError) async {
        if (kDebugMode) {
          print("onError in provider ${onError.message}");
        }
        return onError.message;
      },
      (onData) async {
        if (onData.employees != null && onData.employees!.isNotEmpty) {
          _saveEmployeesLocallyUserCase.call(onData.employees ?? []);
          return onData.employees;
        } else {
          return [] as List<Employee>;
        }
      },
    );
  }

  Future<String> getPlansAndSave(
    UserModel userModel,
    List<Employee> employees,
  ) async {
    final List<Plan> plans = [];
    final List<String> errors = [];

    if (employees.isEmpty || userModel.deviceID == null) {
      return "failed-to-process".tr();
    }
    final futures = employees.map((employee) async {
      final result = await _getPlanUseCase.call(
        userModel.deviceID.toString(),
        employee.id ?? -1,
      );

      await result.fold(
        (onError) async {
          if (kDebugMode) {
            print("onError in provider ${onError.message}");
          }
          errors.add(onError.message);
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
    if (errors.isNotEmpty) {
      return errors.join(", ");
    } else {
      return "";
    }
  }

  Future<String> getDepaRestantAndEmployeesStates(
    UserModel userModel,
    List<Employee> employees,
  ) async {
    if (employees.isEmpty || userModel.deviceID == null) {
      return "failed-to-process".tr();
    }

    final List<EmployeeActionState> actionStates = [];
    final List<EmployeePerformState> performStates = [];
    final List<DepaRestantModel> depaRestants = [];
    final List<String> errors = [];

    final futures = employees.map((employee) async {
      final empId = employee.id ?? -1;

      final resultDepaAndRestant = _getDepaRestantsUseCase.call(
        userModel.deviceID.toString(),
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
      return errors.join(", ");
    } else {
      return "";
    }
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
          employeeActionState.checkInTime = latestActionTime;
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
}
