import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/local/employee_performs_state.dart';
import 'package:verby_flutter/domain/repositories/employee_local_repository.dart';

class GetEmpPerformStatesCase {
  final EmployeeLocalRepository repository;

  GetEmpPerformStatesCase(this.repository);

  Future<Either<String, List<EmployeePerformState>?>> call() async {
    return await repository.getEmployeePerformState();
  }
}
