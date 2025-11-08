import 'package:verby_flutter/data/models/remote/employee.dart';

class VolunteerScreenState {
  final bool isLoading;
  final String? error;
  final int selectedIndex;
  final List<Employee>? employees;
  final List<Employee>? filterList;

  VolunteerScreenState({
    this.isLoading = false,
    this.error = "",
    this.selectedIndex = -1,
    this.employees,
    this.filterList,
  });

  VolunteerScreenState copyWith({
    bool? isLoading,
    String? error,
    int? selectedIndex,
    List<Employee>? employees,
    List<Employee>? filterList,
  }) {
    return VolunteerScreenState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      employees: employees ?? this.employees,
      filterList: filterList ?? this.filterList,
    );
  }
}
