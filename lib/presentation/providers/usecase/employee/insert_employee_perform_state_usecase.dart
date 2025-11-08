import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/domain/use_cases/employee/insert_employee_perform_states.dart';
import '../../../../domain/use_cases/employee/insert_employee_perform_state.dart';
import '../../reposiory/employee_local_repo_provider.dart';


final insertEmployeePerformStatesUseCaseProvider = Provider<InsertEmployeePerformStates>((ref) {
  return InsertEmployeePerformStates(ref.watch(employeeLocalRepoProvider));
});

final insertEmployeePerformStateUseCaseProvider = Provider<InsertEmployeePerformState>((ref) {
  return InsertEmployeePerformState(ref.watch(employeeLocalRepoProvider));
});
