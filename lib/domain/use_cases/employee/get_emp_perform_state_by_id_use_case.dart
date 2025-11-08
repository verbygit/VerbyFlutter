import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/local/employee_performs_state.dart';
import 'package:verby_flutter/data/models/remote/employee_list_response.dart';
import 'package:verby_flutter/domain/repositories/employee_local_repository.dart';
import 'package:verby_flutter/domain/repositories/employee_remote_repository.dart';

import '../../core/failure.dart';

class GetEmpPerformStateByIdUseCase {
  final EmployeeLocalRepository repository;

  GetEmpPerformStateByIdUseCase(this.repository);

  Future<Either<String, EmployeePerformState?>> call(String id) async {
    return await repository.getEmployeePerformStateById(id);
  }
}
