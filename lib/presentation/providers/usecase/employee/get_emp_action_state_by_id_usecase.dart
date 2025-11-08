import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/use_cases/employee/get_emp_action_state_by_id_use_case.dart';
import '../../reposiory/employee_local_repo_provider.dart';

final getEmpActionStateByIdProvider = Provider<GetEmpActionStateByIdUseCase>((ref) {
  return GetEmpActionStateByIdUseCase(ref.watch(employeeLocalRepoProvider));
});
