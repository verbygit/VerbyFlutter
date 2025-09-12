import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/data/models/remote/employee_list_response.dart';
import 'package:verby_flutter/domain/repositories/employee_local_repository.dart';
import 'package:verby_flutter/domain/repositories/employee_remote_repository.dart';

import '../../core/failure.dart';

class GetLocalEmployeeUseCase {
   final EmployeeLocalRepository _repository;

  GetLocalEmployeeUseCase(this._repository);

  Future<Either<String, List<Employee>>> call() async {
    return await _repository.getEmployees();
  }
}
