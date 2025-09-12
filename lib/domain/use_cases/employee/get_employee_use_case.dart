import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/remote/employee_list_response.dart';
import 'package:verby_flutter/domain/repositories/employee_remote_repository.dart';

import '../../core/failure.dart';

class GetEmployeeUseCase {
  final EmployeeRemoteRepository repository;

  GetEmployeeUseCase(this.repository);

  Future<Either<Failure, EmployeeListResponse>> call(int deviceID,) async {
    return await repository.getEmployees(deviceID);
  }
}