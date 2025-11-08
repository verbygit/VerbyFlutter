import 'package:verby_flutter/domain/repositories/record_local_repository.dart';


class ClearRecordUseCase {
  final RecordLocalRepository repository;

  ClearRecordUseCase(this.repository);

  Future<bool> call() async {
    return await repository.clearRecords();
  }
}
