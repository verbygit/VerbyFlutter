import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/domain/use_cases/employee/get_emp_perform_state_by_id_use_case.dart';

import '../../reposiory/employee_local_repo_provider.dart';


final getEmpPerformStateByIdProvider = Provider<GetEmpPerformStateByIdUseCase>((ref) {
  return GetEmpPerformStateByIdUseCase(ref.watch(employeeLocalRepoProvider));
});
