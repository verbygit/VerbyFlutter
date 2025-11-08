import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/local/local_record.dart';

abstract class RecordLocalRepository {
  Future<bool> insetRecord(LocalRecord record);

  Future<Either<String, List<LocalRecord>>> getRecords();

  Future<bool> clearRecords();

}
