import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/domain/entities/states/identification_dialog_state.dart';
import 'package:verby_flutter/domain/use_cases/employee/get_local_employee_usecase.dart';
import 'package:verby_flutter/presentation/providers/usecase/face/delete_face_use_case_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/employee/get_local_employee_usecase_provider.dart';

import '../../domain/use_cases/face/delete_face_use_case.dart';

class DeleteFaceDialogNotifier
    extends StateNotifier<IdentificationDialogState> {
  final DeleteFaceUseCase _deleteFaceUseCase;
  final GetLocalEmployeeUseCase _getLocalEmployeeUseCase;

  DeleteFaceDialogNotifier(
    this._getLocalEmployeeUseCase,
    this._deleteFaceUseCase,
  ) : super(IdentificationDialogState());

  Future<List<Employee>> getEmployees() async {
    final result = await _getLocalEmployeeUseCase.call();
    return result.fold(
      (onError) {
        state = state.copyWith(isLoading: false, error: onError);
        return [];
      },
      (onData) {
        return onData;
      },
    );
  }

  Future<bool> deleteFace(String empID) async {
    final result = await _deleteFaceUseCase.call(empID);

    return result.fold(
      (onError) {
        state = state.copyWith(isLoading: false, error: onError);
        return false;
      },
      (onData) {
        return true;
      },
    );
  }

  void setError(String error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: "");
  }
}

final deleteFaceDialogProvider =
    StateNotifierProvider.autoDispose<
      DeleteFaceDialogNotifier,
      IdentificationDialogState
    >((ref) {
      final getLocalEmployeeUseCase = ref.watch(
        getLocalEmployeeUseCaseProvider,
      );
      final deleteFaceUseCase = ref.read(deleteFaceUseCaseProvider);
      return DeleteFaceDialogNotifier(
        getLocalEmployeeUseCase,
        deleteFaceUseCase,
      );
    });
