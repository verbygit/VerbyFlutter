import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/domain/use_cases/employee/delete_performance_state_use_case.dart';
import '../../reposiory/employee_local_repo_provider.dart';

final deleteEmpPerformStateProvider = Provider<DeletePerformanceStateUseCase>((
  ref,
) {
  return DeletePerformanceStateUseCase(ref.watch(employeeLocalRepoProvider));
});
