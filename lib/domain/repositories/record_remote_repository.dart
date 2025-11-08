import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/remote/employee_list_response.dart';
import 'package:verby_flutter/data/models/remote/record_response.dart';
import '../../data/models/remote/record/CreateRecordRequest.dart';
import '../../data/models/remote/record/create_multi_record_request.dart';
import '../../data/models/remote/server_response.dart';
import '../core/failure.dart';

abstract class RecordRemoteRepository {
  Future<Either<Failure, RecordResponse>> getRecord(int employeeID);

  Future<Either<Failure, ServerResponse>> createRecord(
    CreateRecordRequest createRecordRequest,
  );
  Future<Either<Failure, ServerResponse>> createMultiRecord(
      CreateMultiRecordRequest createRecordRequest,
      );
}
