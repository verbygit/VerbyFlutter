import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/domain/use_cases/plan/get_plan_by_emp_id_use_case.dart';
import 'package:verby_flutter/presentation/providers/reposiory/plan_local_repo_provider.dart';

final getPlanByEmpIdProvider = Provider<GetPlanByEmpIdUseCase>((ref) {
  final repository = ref.watch(planLocalRepoProvider);
  return GetPlanByEmpIdUseCase(repository);
});
