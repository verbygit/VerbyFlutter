import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verby_flutter/data/models/local/face_model.dart';
import 'package:verby_flutter/data/models/remote/record/CreateRecordRequest.dart';
import 'package:verby_flutter/data/models/remote/user_model.dart';
import 'package:verby_flutter/domain/use_cases/employee/get_local_employee_usecase.dart';
import 'package:verby_flutter/domain/use_cases/record/clear_record_use_case.dart';
import 'package:verby_flutter/domain/use_cases/record/create_multi_record_remotely__use_case.dart';
import 'package:verby_flutter/domain/use_cases/record/get_local_record_usecase.dart';
import 'package:verby_flutter/domain/use_cases/sync/sync_data_use_case.dart';
import 'package:verby_flutter/presentation/providers/reposiory/face_repo_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/employee/get_local_employee_usecase_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/record/clear_record_usecase_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/record/create_multi_remote_record.dart';
import 'package:verby_flutter/presentation/providers/usecase/record/get_records_usecase_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/sync/sync_data_use_case_provider.dart';
import '../../data/data_source/local/shared_preference_helper.dart';
import '../../data/models/remote/employee.dart';
import '../../data/models/remote/record/create_multi_record_request.dart';
import '../../domain/core/connectivity_helper.dart';
import '../../domain/entities/states/worker_screen_state.dart';
import '../../domain/repositories/face_repository.dart';

class WorkerScreenProviderNotifier extends StateNotifier<WorkerScreenState> {
  final GetLocalEmployeeUseCase _getLocalEmpUseCase;
  final CreateMultiRecordRemotelyUseCase _createMultiRecordRemotelyUseCase;
  final GetLocalRecordUseCase _getLocalRecordUseCase;
  final ClearRecordUseCase _clearRecordUseCase;
  final SyncDataUseCase _syncDataUseCase;
  final FaceRepository faceRepository;

  WorkerScreenProviderNotifier(
    this._getLocalEmpUseCase,
    this._createMultiRecordRemotelyUseCase,
    this._getLocalRecordUseCase,
    this._clearRecordUseCase,
    this._syncDataUseCase,
    this.faceRepository,
  ) : super(WorkerScreenState()) {
    getEmployees();
    setSharedPreferencesHelper();
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

  void setSharedPreferencesHelper() async {
    final sharedPreferencesHelper = SharedPreferencesHelper(
      await SharedPreferences.getInstance(),
    );
    state = state.copyWith(sharedPreferencesHelper: sharedPreferencesHelper);
    setFaceInfo();
  }

  void setFaceInfo() async {
    final sharedPreferencesHelper = state.sharedPreferencesHelper;
    final isFaceForAll = await sharedPreferencesHelper?.isFaceIdForAll();
    final isFaceForRegisterFace = await sharedPreferencesHelper
        ?.isFaceIdForRegisterFace();
    state = state.copyWith(
      sharedPreferencesHelper: sharedPreferencesHelper,
      isFaceIdForAll: isFaceForAll,
      isFaceForRegisterFace: isFaceForRegisterFace,
    );
  }

  void syncData() async {
    setIsSyncing(true);
    await uploadLocalRecord();
    if (state.isInternetConnected) {
      if (state.employees != null &&
          state.employees?.isNotEmpty == true &&
          state.userModel != null &&
          state.userModel?.deviceID != null) {
        final result = await _syncDataUseCase.syncData(state.userModel!, true);
        if (result.isNotEmpty) {
          setErrorMessage(result);
        }
      }
    }

    await getEmployees();
    setIsSyncing(false);
  }

  void setMessage(String message) {
    state = state.copyWith(message: message);
  }

  void setErrorMessage(String message) {
    state = state.copyWith(errorMessage: message);
  }

  void setIsSyncing(bool isSyncing) {
    state = state.copyWith(isSyncing: isSyncing);
  }

  Future<void> getEmployees() async {
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

  Future<void> uploadLocalRecord() async {
    final localRecordsResult = await _getLocalRecordUseCase.call();
    localRecordsResult.fold(
      ((onError) async {
        if (kDebugMode) {
          print(onError);
        }
      }),
      (onData) async {
        if (onData.isNotEmpty) {
          final records = onData
              .map(
                (e) => CreateRecordRequest(
                  action: e.action,
                  device: e.device,
                  employee: e.employee,
                  identity: e.identity,
                  perform: e.perform,
                  time: e.time,
                  depa: e.depa,
                  restant: e.restant,
                ),
              )
              .toList();

          final createMultiRecordRequest = CreateMultiRecordRequest(
            records: records,
          );
          final result = await _createMultiRecordRemotelyUseCase.call(
            createMultiRecordRequest,
          );
          result.fold(
            (onError) {
              if (kDebugMode) {
                print(onError);
              }
            },
            (onData) async {
              await _clearRecordUseCase.call();
              state = state.copyWith(message: "record_sent_success".tr());
            },
          );
        } else {
          if (kDebugMode) {
            print("Local records are empty===========>");
          }
        }
      },
    );
  }

  void saveUser(UserModel user) {
    state = state.copyWith(userModel: user);
  }

  void saveInternetStatus(bool isConnected) {
    state = state.copyWith(isInternetConnected: isConnected);
  }

  Employee? getEmployeeById(int id) {
    print("getEmployeeById======================> invoked  id : $id");
    final employees = state.employees;
    print("getEmployeeById employees=============> $employees");
    if (employees != null) {
      for (var employee in employees) {
        print(
          "getEmployeeById loop  employee=============> id: ${employee.id}",
        );
        if (employee.id == id) {
          return employee;
        }
      }
    }
    return null;
  }

  Future<FaceModel?> getFaceByEmpId(int empId) async {
    final result = await faceRepository.getFaceByEmployeeId(empId.toString());

    return result.fold(
      (onError) async {
        if (kDebugMode) {
          print(onError);
        }
        return null;
      },
      (OnData) async {
        return OnData;
      },
    );
  }
}

final workerScreenProvider =
    StateNotifierProvider<WorkerScreenProviderNotifier, WorkerScreenState>((
      ref,
    ) {
      final getLocalEmpUseCase = ref.read(getLocalEmployeeUseCaseProvider);
      final createMultiRecordsUseCase = ref.read(
        createMultiRecordRemoteUseCaseProvider,
      );
      final getLocalRecords = ref.read(getRecordsUseCaseProvider);
      final clearLocalRecordUseCase = ref.read(clearRecordUseCaseProvider);
      final syncDataUseCase = ref.read(syncDataUseCaseProvider);
      final faceRepository = ref.read(faceRepoProvider);
      return WorkerScreenProviderNotifier(
        getLocalEmpUseCase,
        createMultiRecordsUseCase,
        getLocalRecords,
        clearLocalRecordUseCase,
        syncDataUseCase,
        faceRepository,
      );
    });
