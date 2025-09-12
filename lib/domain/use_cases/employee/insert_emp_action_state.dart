import 'package:verby_flutter/domain/repositories/employee_local_repository.dart';
import '../../../data/models/local/employee_action_state.dart';

class InsertEmpActionState {
  final EmployeeLocalRepository _repository;

  InsertEmpActionState(this._repository);

  Future<bool> call(EmployeeActionState employeeActionState) async {
    return await _repository.insetEmployeeActionState(employeeActionState);
  }
}
