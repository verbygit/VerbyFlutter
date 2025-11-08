import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/domain/use_cases/employee/save_employees_locally.dart';

import '../../reposiory/employee_local_repo_provider.dart';

final saveEmployeesLocallyProvider = Provider<SaveEmployeesLocally>((ref) {
  return SaveEmployeesLocally(ref.watch(employeeLocalRepoProvider));
});
