import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/domain/use_cases/depa_restant/delete_depa_restants_use_case.dart';
import 'package:verby_flutter/domain/use_cases/employee/delete_action_state_use_case.dart';
import 'package:verby_flutter/presentation/providers/reposiory/depa_restant_local_repo_provider.dart';
import '../../../../domain/use_cases/employee/get_emp_action_state_by_id_use_case.dart';
import '../../reposiory/employee_local_repo_provider.dart';

final deleteDepaRestantProvider = Provider<DeleteDepaRestantsUseCase>((ref) {
  return DeleteDepaRestantsUseCase(ref.watch(depaRestantLocalRepoProvider));
});
