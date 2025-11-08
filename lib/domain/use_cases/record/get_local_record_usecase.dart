import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/local/local_record.dart';
import 'package:verby_flutter/domain/repositories/record_local_repository.dart';

class GetLocalRecordUseCase {
  final RecordLocalRepository _repository;

  GetLocalRecordUseCase(this._repository);

  Future<Either<String, List<LocalRecord>>> call() async {
    return await _repository.getRecords();
  }
}
