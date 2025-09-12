import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verby_flutter/data/data_source/local/shared_preference_helper.dart';
import 'package:verby_flutter/data/mappers/data_mappers.dart';
import 'package:verby_flutter/domain/entities/states/depa_restant_screen_state.dart';
import 'package:verby_flutter/domain/use_cases/depa_restant/get_depa_restant_by_emp_id_use_case.dart';
import 'package:verby_flutter/domain/use_cases/depa_restant/get_depas_restants_use_case.dart';
import 'package:verby_flutter/presentation/providers/usecase/depa_restant/get_depa_restant_by_emp_id_usecase_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/depa_restant/get_depas_restants_use_case_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/depa_restant/insert_depas_restants_usecase_provider.dart';

import '../../data/models/local/depa_restant_model.dart';
import '../../domain/entities/room_status.dart';
import '../../domain/use_cases/depa_restant/insert_depas_restants_use_case.dart';

class DepaRestantStateNotifier extends StateNotifier<DepaRestantScreenState> {
  final GetDepaRestantByEmpIdUseCase _getDepaRestantByEmpId;
  final GetDepaRestantsUseCase _getDepaRestantsUseCase;
  final InsertDepaRestantsUseCase _insertDepaRestantsUseCase;

  DepaRestantStateNotifier(
    this._getDepaRestantByEmpId,
    this._getDepaRestantsUseCase,
    this._insertDepaRestantsUseCase,
  ) : super(DepaRestantScreenState());

  void setLoading() {
    state = state.copyWith(isLoading: true);
  }

  void setDepasAndRestant(String employeeId) async {
    final depaResult = await _getDepaRestantByEmpId.call(employeeId, true);
    await depaResult.fold(
      (onError) async => state = state.copyWith(error: onError),
      (onData) async =>
          state = state.copyWith(depa: [...?state.depa, ...?onData]),
    );
    final restantResult = await _getDepaRestantByEmpId.call(employeeId, false);
    await restantResult.fold(
      (onError) async =>
          state = state.copyWith(isLoading: false, error: onError),
      (onData) async => state = state.copyWith(
        isLoading: false,
        restant: [...?state.restant, ...?onData],
      ),
    );
  }

  void getDepasAndRestant(int employeeId) async {
    state = state.copyWith(isLoading: true);
    int? deviceID = SharedPreferencesHelper(
      await SharedPreferences.getInstance(),
    ).getInt(SharedPreferencesHelper.DEVICE_ID_KEY);
    final result = await _getDepaRestantsUseCase.call(
      deviceID.toString(),
      employeeId,
    );
    final List<DepaRestantModel> depaRestants = [];

    await result.fold(
      (onError) async {
        state.copyWith(error: onError.message);
      },
      (onData) {
        final depaList = onData.depa
            ?.map(
              (e) => e.toDepaRestantModel(
                employeeId.toString(),
                true,
                RoomStatus.CLEANED.getRoomStatusValue(),
              ),
            )
            .toList();
        final restantList = onData.restant
            ?.map(
              (e) => e.toDepaRestantModel(
                employeeId.toString(),
                false,
                RoomStatus.CLEANED.getRoomStatusValue(),
              ),
            )
            .toList();

        if (depaList != null) depaRestants.addAll(depaList);
        if (restantList != null) depaRestants.addAll(restantList);
      },
    );

    if (depaRestants.isNotEmpty) {
      await _insertDepaRestantsUseCase.call(depaRestants);
      setDepasAndRestant(employeeId.toString());
    }
  }


  void updateDepa(DepaRestantModel depaRestantModel, int index) async {
    final list = state.depa;
    list?[index] = depaRestantModel;
    state = state.copyWith(depa: list);
  }

  void updateRestant(DepaRestantModel depaRestantModel, int index) async {
    final list = state.restant;
    list?[index] = depaRestantModel;
    state = state.copyWith(restant: list);
  }
}

final depaRestantProvider =
    StateNotifierProvider.autoDispose<DepaRestantStateNotifier, DepaRestantScreenState>((
      ref,
    ) {
      final getDepaRestantByEmpId = ref.read(getDepaRestantByEmpIdProvider);
      final getDepaRestant = ref.read(getDepaRestantsUseCaseProvider);
      final insertDepaRestantUseCase = ref.read(
        insertDepaRestantsUseCaseProvider,
      );
      return DepaRestantStateNotifier(
        getDepaRestantByEmpId,
        getDepaRestant,
        insertDepaRestantUseCase,
      );
    });
