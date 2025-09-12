import 'package:dartz/dartz.dart';
import 'package:verby_flutter/core/api_constant.dart';
import 'package:verby_flutter/data/models/remote/employee_list_response.dart';
import 'package:verby_flutter/data/models/remote/record/CreateRecordRequest.dart';
import 'package:verby_flutter/data/models/remote/server_response.dart';
import 'package:verby_flutter/domain/core/failure.dart';
import 'package:verby_flutter/domain/repositories/employee_remote_repository.dart';
import 'package:verby_flutter/domain/repositories/record_remote_repository.dart';

import '../data_source/remote/api_client.dart';
import '../models/remote/record_response.dart';

class RecordRemoteRepositoryImpl extends RecordRemoteRepository {
  final ApiClient apiService;

  RecordRemoteRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, RecordResponse>> getRecord(int employeeID) {
    return apiService.get(
      ApiConstant.records(employeeID.toString()),
      queryParameters: {"limit": 4},
      fromJson: (data) => RecordResponse.fromJson(data),
    );
  }

  @override
  Future<Either<Failure, ServerResponse>> createRecord(
    CreateRecordRequest createRecordRequest,
  ) async {
    return apiService.post(
      ApiConstant.createRecord,
      data: createRecordRequest.toJson(),
      fromJson: (data) => ServerResponse.fromJson(data),
    );
  }
}
