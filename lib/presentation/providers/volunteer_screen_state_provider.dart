import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/domain/use_cases/employee/get_local_employee_usecase.dart';
import 'package:verby_flutter/presentation/providers/usecase/employee/get_local_employee_usecase_provider.dart';
import '../../domain/entities/states/volunteer_screen_state.dart';

class VolunteerScreenStateNotifier extends StateNotifier<VolunteerScreenState> {
  final GetLocalEmployeeUseCase _getLocalEmployeeUseCase;

  VolunteerScreenStateNotifier(this._getLocalEmployeeUseCase)
    : super(VolunteerScreenState());

  void getEmployees() async {
    state = state.copyWith(isLoading: true);
    final employees = await _getLocalEmployeeUseCase.call();
    await employees.fold(
      (onError) {
        if (kDebugMode) {
          print(onError);
        }
        state = state.copyWith(error: onError, isLoading: false);
      },
      (onSuccessResponse) async {
        state = state.copyWith(
          isLoading: false,
          employees: onSuccessResponse,
          filterList: onSuccessResponse,
        );
      },
    );
  }

  void filterItems(String query) {
    final List<Employee>? filteredItems;
    if (query.isNotEmpty) {
       filteredItems = state.employees?.where((item) {
        return item.name?.toLowerCase().contains(query) == true;
      }).toList();
    } else {
      filteredItems= state.employees;
    }
    state = state.copyWith(filterList: filteredItems ?? [],selectedIndex: -1);

  }

  void selectItem(int index) {
    print("select index====> $index");
    state = state.copyWith(selectedIndex: index);
  }
}

final volunteerScreenStateProvider =
    StateNotifierProvider.autoDispose<VolunteerScreenStateNotifier, VolunteerScreenState>((
      ref,
    ) {
      final getLocalEmployeeUseCase = ref.read(getLocalEmployeeUseCaseProvider);
      return VolunteerScreenStateNotifier(getLocalEmployeeUseCase);
    });
