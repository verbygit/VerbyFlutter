import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/domain/entities/states/identification_dialog_state.dart';
import 'package:verby_flutter/domain/use_cases/employee/get_local_employee_usecase.dart';
import 'package:verby_flutter/presentation/providers/usecase/employee/get_local_employee_usecase_provider.dart';

class IdentificationDialogNotifier
    extends StateNotifier<IdentificationDialogState> {
  final GetLocalEmployeeUseCase _getLocalEmployeeUseCase;

  IdentificationDialogNotifier(this._getLocalEmployeeUseCase)
    : super(IdentificationDialogState());

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

  void setError(String error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: "");
  }
}

final identificationDialogProvider =
    StateNotifierProvider.autoDispose<
      IdentificationDialogNotifier,
      IdentificationDialogState
    >((ref) {
      final getLocalEmployeeUseCase = ref.watch(
        getLocalEmployeeUseCaseProvider,
      );
      return IdentificationDialogNotifier(getLocalEmployeeUseCase);
    });
