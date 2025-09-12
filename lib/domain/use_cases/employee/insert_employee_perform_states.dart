import 'package:verby_flutter/data/models/local/employee_performs_state.dart';
import 'package:verby_flutter/domain/repositories/employee_local_repository.dart';

class InsertEmployeePerformStates {
  final EmployeeLocalRepository employeeLocalRepository;

  InsertEmployeePerformStates(this.employeeLocalRepository);

  Future<bool> call(List<EmployeePerformState> employeePerformState) async {
    return await employeeLocalRepository.insetEmployeePerformStates(
      employeePerformState,
    );
  }
}
