import 'package:verby_flutter/data/models/local/employee_performs_state.dart';
import 'package:verby_flutter/domain/repositories/employee_local_repository.dart';

class InsertEmployeePerformState {
  final EmployeeLocalRepository employeeLocalRepository;

  InsertEmployeePerformState(this.employeeLocalRepository);

  Future<bool> call(EmployeePerformState employeePerformState) async {
    return await employeeLocalRepository.insetEmployeePerformState(
      employeePerformState,
    );
  }
}
