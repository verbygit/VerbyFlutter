import 'package:dartz/dartz.dart';
import 'package:verby_flutter/core/api_constant.dart';
import 'package:verby_flutter/data/models/remote/employee_list_response.dart';
import 'package:verby_flutter/domain/core/failure.dart';
import 'package:verby_flutter/domain/repositories/employee_remote_repository.dart';

import '../data_source/remote/api_client.dart';

class EmployeeRemoteRepositoryImpl extends EmployeeRemoteRepository {
  final ApiClient apiService;

  EmployeeRemoteRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, EmployeeListResponse>> getEmployees(int deviceID) {
    return apiService.get(
      ApiConstant.employee,
      queryParameters: {"device_id": deviceID.toString()},
      fromJson: (data) {
        if (data == null || data is String) {
          throw Exception("Invalid data format");
        }
        return EmployeeListResponse.fromJson(data);
      },
    );
  }
}
