import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/domain/use_cases/employee/get_emp_action_states_use_case.dart';
import 'package:verby_flutter/domain/use_cases/employee/get_emp_perform_states_use_case.dart';
import '../../../../domain/use_cases/employee/get_emp_action_state_by_id_use_case.dart';
import '../../reposiory/employee_local_repo_provider.dart';

final getEmpPerformStatesUseCase = Provider<GetEmpPerformStatesCase>((ref) {
  return GetEmpPerformStatesCase(ref.watch(employeeLocalRepoProvider));
});
