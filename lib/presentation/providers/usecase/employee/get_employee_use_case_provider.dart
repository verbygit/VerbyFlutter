import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/domain/use_cases/employee/get_employee_use_case.dart';
import 'package:verby_flutter/presentation/providers/reposiory/auth_repo_provider.dart';
import 'package:verby_flutter/presentation/providers/reposiory/employee_remote_repo_provider.dart';
import '../../../../domain/use_cases/auth/login_use_case.dart';

final getEmployeeUseCaseProvider = Provider<GetEmployeeUseCase>((ref) {
  final employeeRepository = ref.watch(employeeRepositoryProvider);
  return GetEmployeeUseCase(employeeRepository);
});
