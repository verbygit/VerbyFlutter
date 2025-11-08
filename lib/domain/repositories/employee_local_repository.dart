import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/local/employee_performs_state.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';

import '../../data/models/local/employee_action_state.dart';

abstract class EmployeeLocalRepository {
  Future<void> insetEmployees(List<Employee> employees);

  Future<Either<String, List<Employee>>> getEmployees();

  Future<bool> insetEmployeePerformState(
    EmployeePerformState employeePerformState,
  );
  Future<bool> insetEmployeePerformStates(List<EmployeePerformState> employeePerformStates);


  Future<Either<String, EmployeePerformState?>> getEmployeePerformStateById(
    String id,
  );

  Future<Either<String, List<EmployeePerformState>>> getEmployeePerformState();


  Future<bool> insetEmployeeActionState(
    EmployeeActionState employeeActionState,
  );
  Future<bool> insetEmployeeActionStates(List<EmployeeActionState> employeeActionStates);


  Future<Either<String, EmployeeActionState?>> getEmployeeActionStateById(
    String id,
  );

  Future<Either<String, List<EmployeeActionState>>> getEmployeeActionState();

  Future<bool> deleteEmpPerformanceState(String employeeId);
  Future<bool> deleteEmpActionState(String employeeId);


}
