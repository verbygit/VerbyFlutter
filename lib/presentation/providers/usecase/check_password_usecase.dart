import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/domain/use_cases/employee/save_employees_locally.dart';
import 'package:verby_flutter/presentation/providers/reposiory/auth_repo_provider.dart';

import '../../../domain/use_cases/auth/check_password_use_case.dart';
import '../reposiory/employee_local_repo_provider.dart';

final checkPasswordUseCaseProvider = Provider<CheckPassword>((ref) {
  return CheckPassword(ref.watch(authRepositoryProvider));
});
