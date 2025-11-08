import 'package:verby_flutter/data/models/local/local_record.dart';
import '../../repositories/record_local_repository.dart';

class InsertLocalRecordUseCase {
  final RecordLocalRepository _repository;

  InsertLocalRecordUseCase(this._repository);

  Future<bool> call(LocalRecord records) async {
  return  await _repository.insetRecord(records);
  }
}
