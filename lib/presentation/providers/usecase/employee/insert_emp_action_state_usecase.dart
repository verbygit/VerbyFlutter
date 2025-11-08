import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/use_cases/employee/insert_emp_action_state.dart';
import '../../../../domain/use_cases/employee/insert_emp_action_states.dart';
import '../../reposiory/employee_local_repo_provider.dart';

final insertEmpActionStatesUserCaseProvider = Provider<InsertEmpActionStates>((ref) {
  return InsertEmpActionStates(ref.watch(employeeLocalRepoProvider));
});

final insertEmpActionStateUserCaseProvider = Provider<InsertEmpActionState>((ref) {
  return InsertEmpActionState(ref.watch(employeeLocalRepoProvider));
});
