import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/remote/employee_list_response.dart';
import 'package:verby_flutter/data/models/remote/record/CreateRecordRequest.dart';
import 'package:verby_flutter/data/models/remote/record/create_multi_record_request.dart';
import 'package:verby_flutter/domain/repositories/employee_remote_repository.dart';
import 'package:verby_flutter/domain/repositories/record_remote_repository.dart';

import '../../../data/models/remote/record_response.dart';
import '../../../data/models/remote/server_response.dart';
import '../../core/failure.dart';

class CreateMultiRecordRemotelyUseCase {
  final RecordRemoteRepository repository;

  CreateMultiRecordRemotelyUseCase(this.repository);

  Future<Either<Failure, ServerResponse>> call(
    CreateMultiRecordRequest createRecordRequest,
  ) async {
    return await repository.createMultiRecord(createRecordRequest);
  }
}
