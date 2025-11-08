import 'package:dartz/dartz.dart';
import 'package:verby_flutter/domain/repositories/employee_local_repository.dart';
import '../../../data/models/local/employee_action_state.dart';

class GetEmpActionStateByIdUseCase {
  final EmployeeLocalRepository repository;

  GetEmpActionStateByIdUseCase(this.repository);

  Future<Either<String, EmployeeActionState?>> call(String id) async {
    return await repository.getEmployeeActionStateById(id);
  }
}
