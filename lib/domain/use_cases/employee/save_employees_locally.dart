import 'package:verby_flutter/domain/repositories/employee_local_repository.dart';

import '../../../data/models/remote/employee.dart';

class SaveEmployeesLocally {
  final EmployeeLocalRepository employeeLocalRepository;

  SaveEmployeesLocally(this.employeeLocalRepository);

  Future<void> call(List<Employee> employees) async {
    await employeeLocalRepository.insetEmployees(employees);
  }
}
