import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/domain/use_cases/depa_restant/get_depas_restants_use_case.dart';
import 'package:verby_flutter/domain/use_cases/plan/get_plan_use_case.dart';
import 'package:verby_flutter/domain/use_cases/employee/save_employees_locally.dart';
import 'package:verby_flutter/presentation/providers/reposiory/auth_repo_provider.dart';
import 'package:verby_flutter/presentation/providers/reposiory/depa_restant_remote_repo_provider.dart';
import 'package:verby_flutter/presentation/providers/reposiory/plan_remote_repo_provider.dart';

import '../../../../domain/use_cases/auth/check_password_use_case.dart';
import '../../reposiory/employee_local_repo_provider.dart';

final getDepaRestantsUseCaseProvider = Provider<GetDepaRestantsUseCase>((ref) {
  return GetDepaRestantsUseCase(ref.watch(depaRestantRemoteRepoProvider));
});
