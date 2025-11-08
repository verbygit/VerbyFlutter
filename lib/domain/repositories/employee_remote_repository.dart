import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/remote/employee_list_response.dart';
import '../core/failure.dart';

abstract class EmployeeRemoteRepository {
  Future<Either<Failure, EmployeeListResponse>> getEmployees(int deviceID);
}
