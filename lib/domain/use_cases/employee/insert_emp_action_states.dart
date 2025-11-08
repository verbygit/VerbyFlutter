import 'package:verby_flutter/domain/repositories/employee_local_repository.dart';
import '../../../data/models/local/employee_action_state.dart';

class InsertEmpActionStates {
  final EmployeeLocalRepository _repository;

  InsertEmpActionStates(this._repository);

  Future<bool> call(List<EmployeeActionState> employeeActionState) async {
    return await _repository.insetEmployeeActionStates(employeeActionState);
  }
}
