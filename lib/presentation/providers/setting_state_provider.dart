import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verby_flutter/data/data_source/local/shared_preference_helper.dart';
import 'package:verby_flutter/data/models/remote/record/CreateRecordRequest.dart';
import 'package:verby_flutter/domain/use_cases/backup/delete_archive_use_case.dart';
import 'package:verby_flutter/domain/use_cases/face/get_all_face_use_case.dart';
import 'package:verby_flutter/presentation/providers/usecase/face/delete_face_use_case_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/face/get_all_face_use_case_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/face/is_face_exits_use_case_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/record/create_multi_remote_record.dart';
import 'package:verby_flutter/presentation/providers/usecase/sync/sync_data_use_case_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/backup/upload_archive_use_case_provider.dart';
import 'package:verby_flutter/presentation/providers/worker_screen_provider.dart';
import '../../data/models/remote/record/create_multi_record_request.dart';
import '../../domain/core/connectivity_helper.dart';
import '../../domain/entities/states/setting_screen_state.dart';
import '../../domain/use_cases/face/delete_face_use_case.dart';
import '../../domain/use_cases/face/is_face_exists_use_case.dart';
import '../../domain/use_cases/record/create_multi_record_remotely__use_case.dart';
import '../../domain/use_cases/sync/sync_data_use_case.dart';
import '../../domain/use_cases/backup/upload_archive_use_case.dart';

class SettingStateProvider extends StateNotifier<SettingScreenState> {
  final IsFaceExistsUseCase _isFaceExistsUseCase;
  final GetAllFaceUseCase _getAllFaceUseCase;
  final DeleteFaceUseCase _deleteFaceUseCase;
  final SyncDataUseCase _syncDataUseCase;
  final UploadArchiveUseCase _uploadArchiveUseCase;
  final CreateMultiRecordRemotelyUseCase _createMultiRecordRemotelyUseCase;
  final DeleteArchiveUseCase _deleteArchiveUseCase;
  final WorkerScreenProviderNotifier _workerScreenProviderNotifier;

  SettingStateProvider(
    this._isFaceExistsUseCase,
    this._getAllFaceUseCase,
    this._deleteFaceUseCase,
    this._syncDataUseCase,
    this._uploadArchiveUseCase,
    this._createMultiRecordRemotelyUseCase,
    this._deleteArchiveUseCase,
    this._workerScreenProviderNotifier,
  ) : super(
        SettingScreenState(
          isInternetConnected: ConnectivityHelper().isConnected,
        ),
      ) {
    setSharedPreferencesHelper();
    getAllFaces();
  }

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

  Future<bool> deleteFace(String empID) async {
    final result = await _deleteFaceUseCase.call(empID);

    return result.fold(
      (onError) {
        state = state.copyWith(errorMessage: onError);
        return false;
      },
      (onData) {
        return true;
      },
    );
  }

  void getAllFaces() async {
    final result = await _getAllFaceUseCase.call();

    print("Setting provider============>    $result");

    result.fold(
      (onError) => state = state.copyWith(faces: null),
      (onData) => state = state.copyWith(faces: onData),
    );
  }

  void syncData() async {
    if (state.isInternetConnected) {
      state = state.copyWith(isLoading: true);
      final userModel = state.sharedPreferencesHelper?.getUser();
      if (userModel != null && userModel.deviceID != null) {
        final result = await _syncDataUseCase.syncData(userModel, true);
        if (result.isNotEmpty) {
          setErrorMessage(result);
        }else{
          _workerScreenProviderNotifier.getEmployees();
        }
      }
      state = state.copyWith(isLoading: false);
    } else {
      setErrorMessage("no_internet".tr());
    }
  }

  Future<bool> checkIsFaceExists(String emplID) async {
    final result = await _isFaceExistsUseCase.call(emplID);
    print("checkIsFaceExists============>    $result");
    return await result.fold(
      (onError) async {
        return false;
      },
      (onData) async {
        return onData;
      },
    );
  }

  void setSharedPreferencesHelper() async {
    final sharedPreferencesHelper = SharedPreferencesHelper(
      await SharedPreferences.getInstance(),
    );
    final isFaceForAll = await sharedPreferencesHelper.isFaceIdForAll();
    final isFaceForRegisterFace = await sharedPreferencesHelper
        .isFaceIdForRegisterFace();
    final faceVerificationTries = await sharedPreferencesHelper.getFaceTries();
    state = state.copyWith(
      sharedPreferencesHelper: sharedPreferencesHelper,
      isFaceIdForAll: isFaceForAll,
      isFaceForRegisterFace: isFaceForRegisterFace,
      faceVerificationTries: faceVerificationTries,
    );
  }

  Future<void> setFaceIDForAll(bool value) async {
    final sharedPreferencesHelper = state.sharedPreferencesHelper;
    if (sharedPreferencesHelper != null) {
      await sharedPreferencesHelper.setFaceIdForAll(value);
    }
    if (value) {
      await setFaceIDForRegisterFace(false);
    }
    state = state.copyWith(isFaceIdForAll: value);
  }

  Future<void> setFaceIDForRegisterFace(bool value) async {
    final sharedPreferencesHelper = state.sharedPreferencesHelper;
    if (sharedPreferencesHelper != null) {
      await sharedPreferencesHelper.setFaceIdForRegisterFace(value);
    }
    if (value) {
      await setFaceIDForAll(false);
    }
    state = state.copyWith(isFaceForRegisterFace: value);
  }

  Future<void> setFaceTries(double value) async {
    final sharedPreferencesHelper = state.sharedPreferencesHelper;
    if (sharedPreferencesHelper != null) {
      await sharedPreferencesHelper.setFaceVerificationTries(value);
    }

    state = state.copyWith(faceVerificationTries: value);
  }

  void setInternetConnected(bool value) {
    state = state.copyWith(isInternetConnected: value);
  }

  void setErrorMessage(String value) {
    state = state.copyWith(errorMessage: value);
  }

  void setMessage(String value) {
    state = state.copyWith(message: value);
  }

  Future<void> uploadArchive() async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    final result = await _uploadArchiveUseCase.call();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure);
      },
      (records) async {
        final result = await uploadRecordsFromArchive(records);
        if (result) {
          await _deleteArchiveUseCase.call();

          state = state.copyWith(
            isLoading: false,
            message: 'record_sent_success'.tr(),
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'failed_to_process'.tr(),
          );
        }
      },
    );
  }

  Future<bool> uploadRecordsFromArchive(
    List<CreateRecordRequest> records,
  ) async {
    final createMultiRecordRequest = CreateMultiRecordRequest(records: records);
    final result = await _createMultiRecordRemotelyUseCase.call(
      createMultiRecordRequest,
    );
    return await result.fold(
      (onError) async {
        return false;
      },
      (onData) async {
        return true;
      },
    );
  }
}

final settingScreenStateProvider =
    StateNotifierProvider.autoDispose<SettingStateProvider, SettingScreenState>(
      (ref) {
        final isFaceExits = ref.read(isFaceExistsUseCaseProvider);
        final getAllFacesUseCase = ref.read(getAllFacesUseCaseProvider);
        final deleteFaceUseCase = ref.read(deleteFaceUseCaseProvider);
        final syncDataUseCase = ref.read(syncDataUseCaseProvider);
        final uploadArchiveUseCase = ref.read(uploadArchiveUseCaseProvider);
        final createMultiRecordsUseCase = ref.read(
          createMultiRecordRemoteUseCaseProvider,
        );
        final deleteArchiveUseCase = ref.read(deleteArchiveUseCaseProvider);
        final workerScreenNotifier= ref.read(workerScreenProvider.notifier);
        return SettingStateProvider(
          isFaceExits,
          getAllFacesUseCase,
          deleteFaceUseCase,
          syncDataUseCase,
          uploadArchiveUseCase,
          createMultiRecordsUseCase,
          deleteArchiveUseCase,
          workerScreenNotifier
        );
      },
    );
