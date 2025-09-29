import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verby_flutter/core/date_time_helper.dart';
import 'package:verby_flutter/data/data_source/local/shared_preference_helper.dart';
import 'package:verby_flutter/data/models/local/depa_restant_model.dart';
import 'package:verby_flutter/data/models/local/employee_performs_state.dart';
import 'package:verby_flutter/data/models/local/local_record.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/data/models/remote/record/CreateRecordRequest.dart';
import 'package:verby_flutter/data/models/remote/record/depa_record.dart';
import 'package:verby_flutter/data/models/remote/record/restant_record.dart';
import 'package:verby_flutter/data/service/backup_service.dart';
import 'package:verby_flutter/domain/core/connectivity_helper.dart';
import 'package:verby_flutter/domain/entities/action.dart';
import 'package:verby_flutter/domain/entities/perform.dart';
import 'package:verby_flutter/domain/entities/room_status.dart';
import 'package:verby_flutter/domain/entities/states/empPerformAndActionState.dart';
import 'package:verby_flutter/domain/use_cases/depa_restant/delete_depa_restants_use_case.dart';
import 'package:verby_flutter/domain/use_cases/employee/delete_performance_state_use_case.dart';
import 'package:verby_flutter/domain/use_cases/employee/get_emp_perform_state_by_id_use_case.dart';
import 'package:verby_flutter/domain/use_cases/record/create_record_remotely__use_case.dart';
import 'package:verby_flutter/domain/use_cases/record/get_local_record_usecase.dart';
import 'package:verby_flutter/domain/use_cases/record/insert_local_record_use_case.dart';
import 'package:verby_flutter/domain/use_cases/sync/sync_data_use_case.dart';
import 'package:verby_flutter/presentation/providers/usecase/depa_restant/delete_depa_restants_usecase_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/employee/delete_emp_action_state_usecase_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/employee/delete_emp_perform_state_usecase_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/employee/get_emp_action_state_by_id_usecase.dart';
import 'package:verby_flutter/presentation/providers/usecase/employee/get_emp_perform_state_by_id_usecase.dart';
import 'package:verby_flutter/presentation/providers/usecase/employee/insert_emp_action_state_usecase.dart';
import 'package:verby_flutter/presentation/providers/usecase/employee/insert_employee_perform_state_usecase.dart';

import 'package:verby_flutter/presentation/providers/usecase/record/create__remote_record.dart';
import 'package:verby_flutter/presentation/providers/usecase/record/get_records_usecase_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/record/insert_record_usecase_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/sync/sync_data_use_case_provider.dart';

import '../../data/models/local/employee_action_state.dart';
import '../../data/models/remote/user_model.dart';
import '../../domain/use_cases/employee/delete_action_state_use_case.dart';
import '../../domain/use_cases/employee/get_emp_action_state_by_id_use_case.dart';
import '../../domain/use_cases/employee/insert_emp_action_state.dart';
import '../../domain/use_cases/employee/insert_employee_perform_state.dart';

class EmpPerformAndActionStateNotifier
    extends StateNotifier<EmployeePerformAndActionState> {
  final InsertEmployeePerformState _insertEmpPerformState;
  final InsertEmpActionState _insertEmpActionState;
  final CreateRecordRemotelyUseCase _createRecordRemotelyUseCase;
  final GetEmpActionStateByIdUseCase _getEmpActionStateById;
  final GetEmpPerformStateByIdUseCase _getEmpPerformStateById;
  final DeletePerformanceStateUseCase _deleteEmpPerformState;
  final DeleteActionStateUseCase _deleteEmpActionState;
  final DeleteDepaRestantsUseCase _deleteDepaRestantsUseCase;
  final InsertLocalRecordUseCase _insertLocalRecordUseCase;
  final SyncDataUseCase _syncDataUseCase;
  final GetLocalRecordUseCase getLocalRecordUseCase;

  EmpPerformAndActionStateNotifier(
    this._insertEmpPerformState,
    this._insertEmpActionState,
    this._createRecordRemotelyUseCase,
    this._getEmpActionStateById,
    this._getEmpPerformStateById,
    this._deleteEmpPerformState,
    this._deleteEmpActionState,
    this._deleteDepaRestantsUseCase,
    this._insertLocalRecordUseCase,
    this._syncDataUseCase,
    this.getLocalRecordUseCase,
  ) : super(
        EmployeePerformAndActionState(
          isInternetConnected: ConnectivityHelper().isConnected,
        ),
      );

  void listenToInternetStatus() {
    ConnectivityHelper().onStatusChange.listen((onData) {
      if (onData == ConnectivityStatus.online) {
        saveInternetStatus(true);
      } else {
        saveInternetStatus(false);
      }
    });
  }

  void saveInternetStatus(bool isConnected) {
    state = state.copyWith(isInternetConnected: isConnected);
  }

  void setErrorMessage(String message) {
    state = state.copyWith(errorMessage: message);
  }

  void setSuccessMessage(String message) {
    state = state.copyWith(message: message);
  }

  Future<void> syncSingleEmpData(Employee employee) async {
    state = state.copyWith(isLoading: true);
    UserModel? userModel = SharedPreferencesHelper(
      await SharedPreferences.getInstance(),
    ).getUser();

    state = state.copyWith(user: userModel);

    if (state.isInternetConnected) {
      if (userModel != null) {
        final result = await _syncDataUseCase.syncSingleEmpData(
          userModel,
          employee.id ?? -1,
        );

        if (result.isNotEmpty) {
          state = state.copyWith(isLoading: false, errorMessage: result);
          return;
        }
      }
    }

    if (employee.id != null) {
      await setCurrentPerformAndActionState(employee.id!);
    }
    state = state.copyWith(isLoading: false,);
  }

  Future<void> syncData(Employee employee) async {
    state = state.copyWith(isLoading: true);
    if (state.isInternetConnected) {
      UserModel? userModel = SharedPreferencesHelper(
        await SharedPreferences.getInstance(),
      ).getUser();

      state = state.copyWith(user: userModel);
      if (userModel != null) {
        final result = await _syncDataUseCase.syncData(userModel, false);
        if (result.isNotEmpty) {
          print("syncData perform  ============> error message $result");
          state = state.copyWith(errorMessage: result);
        } else {
          if (employee.id != null) {
            await setCurrentPerformAndActionState(employee.id!);
          }
        }
      }
    } else {
      if (employee.id != null) {
        await setCurrentPerformAndActionState(employee.id!);
      }
    }
    state = state.copyWith(isLoading: false);
  }

  Future<bool> createRecord(
    Employee employee,
    Perform perform,
    Action action,
    List<DepaRestantModel?>? depa,
    List<DepaRestantModel?>? restant,
  ) async {
    state = state.copyWith(isLoading: true);
    final user = state.user;

    final time = DateTimeHelper.getRecordFormatDate();

    final depaRecordList = depa
        ?.map(
          (depaRestantModel) =>
              DepaRecord.fromDepaRestantModel(depaRestantModel),
        )
        .toList();
    final restantRecordList = restant
        ?.map(
          (depaRestantModel) =>
              RestantRecord.fromDepaRestantModel(depaRestantModel),
        )
        .toList();

    final recordRequest = CreateRecordRequest(
      employee: employee.id,
      device: user?.deviceID ?? -1,
      action: action.getActionValue(),
      perform: perform.getPerformValue(),
      identity: 1,
      time: time,
      depa: depaRecordList,
      restant: restantRecordList,
    );
    String errorMessage = "";
    if (state.isInternetConnected) {
      errorMessage = await createRecordOnServer(recordRequest);
    } else {
      errorMessage = await createRecordLocally(recordRequest);
    }
    if (errorMessage.isNotEmpty) {
      state = state.copyWith(errorMessage: errorMessage);
      return false;
    }
    final empActionState = createEmployeeActionState(
      time ?? "",
      employee.id ?? -1,
      action,
    );
    final empPerformState = createEmployeePerformState(
      employee.id ?? -1,
      perform,
    );
    await _insertEmpActionState.call(empActionState);

    if (action != Action.CHECKOUT) {
      await _insertEmpPerformState.call(empPerformState);
    } else {
      _deleteEmpPerformState.call(employee.id.toString());
    }
    String successMessage = createSuccessMessage(empActionState, action);
    state = state.copyWith(message: successMessage);
    await deleteDepaRestants(depa, restant);
    state = state.copyWith(isLoading: false, message: successMessage);
    return true;
  }

  Future<String> createRecordLocally(CreateRecordRequest request) async {
    try {
      final result = await _insertLocalRecordUseCase.call(
        LocalRecord(
          id: DateTime.now().millisecondsSinceEpoch,
          request: request,
        ),
      );
      if (result) {
        final records = await getLocalRecordUseCase.call();
        await records.fold(((onError) async {}), (onData) async {
          BackupService().saveRecordsWithBackup(onData);
        });
        return "";
      } else {
        return "failed-to-process".tr();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return e.toString();
    }
  }

  Future<String> createRecordOnServer(CreateRecordRequest request) async {
    final result = await _createRecordRemotelyUseCase.call(request);
    return await result.fold(
      (onError) async {
        state = state.copyWith(isLoading: false, errorMessage: onError.message);
        return onError.message;
      },
      (onData) async {
        return "";
      },
    );
  }

  Future<bool> deleteDepaRestants(
    List<DepaRestantModel?>? depas,
    List<DepaRestantModel?>? restants,
  ) async {
    if (depas != null && restants != null) {
      List<String> depaIds = depas
          .where(
            (depa) =>
                RoomStatus.getRoomStatus(depa?.status ?? 0) !=
                RoomStatus.DEFAULT,
          )
          .toList()
          .map((depas) => depas?.id.toString() ?? "")
          .toList();

      List<String> restantIds = restants
          .where(
            (restant) =>
                RoomStatus.getRoomStatus(restant?.status ?? 0) !=
                RoomStatus.DEFAULT,
          )
          .toList()
          .map((restant) => restant?.id.toString() ?? "")
          .toList();
      depaIds.addAll(restantIds);
      return await _deleteDepaRestantsUseCase.call(depaIds);
    }
    return true;
  }

  String createSuccessMessage(
    EmployeeActionState empActionState,
    Action action,
  ) {
    if (action != Action.CHECKOUT) return "thank".tr();
    double workerHours = DateTimeHelper.getWorkingHours(
      empActionState.lastActionTime,
    );

    if (workerHours > 5.5 && empActionState.hadAPause == false) {
      return "thank_with_pause".tr();
    } else {
      return "thank".tr();
    }
  }

  Future<void> setCurrentPerformAndActionState(int employeeId) async {
    final empPerformStateResult = await _getEmpPerformStateById.call(
      employeeId.toString(),
    );
    final empActionStateResult = await _getEmpActionStateById.call(
      employeeId.toString(),
    );

    await empPerformStateResult.fold(
      (onError) async {
        state = state.copyWith(errorMessage: "failed-to-process".tr());
      },
      (onData) async {
        EmployeePerformState? employeePerformState = onData;
        employeePerformState ??= EmployeePerformState(
          id: employeeId,
          isBuro: true,
          isMaintenance: true,
          isRoomCleaning: true,
          isRoomControl: true,
          isStewarding: true,
        );
        state = state.copyWith(currentEmpPerformState: employeePerformState);
      },
    );
    await empActionStateResult.fold(
      (onError) async {
        state = state.copyWith(errorMessage: "failed-to-process".tr());
      },
      (onData) async {
        state = state.copyWith(currentEmpActionState: onData);
      },
    );
  }

  EmployeePerformState createEmployeePerformState(
    int employeeId,
    Perform perform,
  ) {
    var employeePerformState = EmployeePerformState(id: employeeId);

    switch (perform) {
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

  EmployeeActionState createEmployeeActionState(
    String time,
    int employeeId,
    Action action,
  ) {
    EmployeeActionState employeeActionState = EmployeeActionState(
      id: employeeId,
      lastActionTime: time,
    );

    switch (action) {
      case Action.CHECKIN:
        {
          employeeActionState.checkedIn = false;
          employeeActionState.pausedOut = false;
          employeeActionState.checkInTime = time;
        }
        break;
      case Action.PAUSEIN:
        {
          employeeActionState.pausedIn = false;
          employeeActionState.checkedIn = false;
          employeeActionState.checkedOut = false;
          employeeActionState.hadAPause = true;

          employeeActionState.checkInTime =
              state.currentEmpActionState?.checkInTime ?? "";
        }
        break;
      case Action.PAUSEOUT:
        {
          employeeActionState.pausedOut = false;
          employeeActionState.checkedIn = false;

          employeeActionState.checkInTime =
              state.currentEmpActionState?.checkInTime ?? "";
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

final empPerformAndActionStateProvider =
    StateNotifierProvider<
      EmpPerformAndActionStateNotifier,
      EmployeePerformAndActionState
    >((ref) {
      final insertEmpPerformState = ref.read(
        insertEmployeePerformStateUseCaseProvider,
      );
      final insertEmpActionState = ref.read(
        insertEmpActionStateUserCaseProvider,
      );

      final getEmpActionStateById = ref.read(getEmpActionStateByIdProvider);
      final getEmpPerformStateById = ref.read(getEmpPerformStateByIdProvider);
      final createRecordRemotelyUseCase = ref.read(
        createRecordRemotelyUseCaseProvider,
      );
      final deleteEmpActionStateUseCase = ref.read(
        deleteEmpActionStateProvider,
      );
      final deleteEmpPerformStateUseCase = ref.read(
        deleteEmpPerformStateProvider,
      );
      final getRecordUseCase = ref.read(getRecordsUseCaseProvider);
      final insertRecordUseCase = ref.read(insertRecordUseCaseProvider);
      final deleteDepaRestantsUseCase = ref.read(deleteDepaRestantProvider);
      final syncDataUseCase = ref.read(syncDataUseCaseProvider);
      return EmpPerformAndActionStateNotifier(
        insertEmpPerformState,
        insertEmpActionState,
        createRecordRemotelyUseCase,
        getEmpActionStateById,
        getEmpPerformStateById,
        deleteEmpPerformStateUseCase,
        deleteEmpActionStateUseCase,
        deleteDepaRestantsUseCase,
        insertRecordUseCase,
        syncDataUseCase,
        getRecordUseCase,
      );
    });
