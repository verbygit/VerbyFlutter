import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/remote/employee_list_response.dart';
import 'package:verby_flutter/domain/repositories/employee_remote_repository.dart';
import 'package:verby_flutter/domain/repositories/record_remote_repository.dart';

import '../../../data/models/remote/record_response.dart';
import '../../core/failure.dart';

class GetRecordFromServerUseCase {
  final RecordRemoteRepository repository;

  GetRecordFromServerUseCase(this.repository);

  Future<Either<Failure, RecordResponse>> call(int employeeId) async {
    return await repository.getRecord(employeeId);
  }
}
