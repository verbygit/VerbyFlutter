import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/domain/use_cases/sync/sync_data_use_case.dart';
import 'package:verby_flutter/presentation/providers/usecase/employee/get_local_employee_usecase_provider.dart';
import 'package:verby_flutter/presentation/providers/usecase/employee/save_employee_locally_usecase.dart';
import '../depa_restant/delete_depa_restants_by_emp_usecase_provider.dart';
import '../depa_restant/get_depas_restants_use_case_provider.dart';
import '../depa_restant/insert_depas_restants_usecase_provider.dart';
import '../employee/delete_emp_perform_state_usecase_provider.dart';
import '../employee/get_employee_use_case_provider.dart';
import '../employee/insert_emp_action_state_usecase.dart';
import '../employee/insert_employee_perform_state_usecase.dart';
import '../plan/get_plan_use_case_provider.dart';
import '../plan/insert_plans_usecase_provider.dart';
import '../record/get_record_use_case_provider.dart';

final syncDataUseCaseProvider = Provider<SyncDataUseCase>((ref) {
  final getRecordUseCase = ref.read(getRecordUseCaseProvider);
  final insertEmpPerformState = ref.read(
    insertEmployeePerformStatesUseCaseProvider,
  );
  final insertEmpActionState = ref.read(insertEmpActionStatesUserCaseProvider);
  final getPlanUseCase = ref.read(getPlanUseCaseProvider);
  final getDepaRestantUseCase = ref.read(getDepaRestantsUseCaseProvider);
  final insertPlanUseCase = ref.read(insertPlansUseCaseProvider);
  final insertDepaRestantUseCase = ref.read(insertDepaRestantsUseCaseProvider);
  final saveEmployeesLocallyUseCase = ref.read(saveEmployeesLocallyProvider);
  final getEmployeeUseCase = ref.read(getEmployeeUseCaseProvider);
  final getLocalEmployeesUseCase = ref.read(getLocalEmployeeUseCaseProvider);
  final deleteEmpPerformStateUseCase = ref.read(
    deleteEmpPerformStateProvider,
  );
  final deleteDepaRestantsUseCase = ref.read(deleteDepaRestantByEmpProvider);

  return SyncDataUseCase(
    getRecordUseCase,
    insertEmpPerformState,
    insertEmpActionState,
    getPlanUseCase,
    insertPlanUseCase,
    getDepaRestantUseCase,
    insertDepaRestantUseCase,
    getEmployeeUseCase,
    saveEmployeesLocallyUseCase,
    getLocalEmployeesUseCase,
      deleteEmpPerformStateUseCase,
      deleteDepaRestantsUseCase
  );
});
