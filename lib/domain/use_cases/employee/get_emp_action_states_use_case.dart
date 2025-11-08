import 'package:dartz/dartz.dart';
import 'package:verby_flutter/domain/repositories/employee_local_repository.dart';
import '../../../data/models/local/employee_action_state.dart';

class GetEmpActionStatesCase {
  final EmployeeLocalRepository repository;

  GetEmpActionStatesCase(this.repository);

  Future<Either<String, List<EmployeeActionState>?>> call() async {
    return await repository.getEmployeeActionState();
  }
}
