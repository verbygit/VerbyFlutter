import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:verby_flutter/data/dao/record_dao.dart';
import 'package:verby_flutter/data/models/local/local_record.dart';
import 'package:verby_flutter/domain/repositories/record_local_repository.dart';

class RecordLocalRepositoryImpl extends RecordLocalRepository {
  final RecordDao dao;

  RecordLocalRepositoryImpl(this.dao);

  @override
  Future<bool> insetRecord(LocalRecord record) async {
    try {
      await dao.insertRecord(record);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  @override
  Future<Either<String, List<LocalRecord>>> getRecords() async {
    try {
      var result = await dao.getAllRecord();
      return Right(result);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return Left(e.toString());
    }
  }

  @override
  Future<bool> clearRecords() {
    return dao.clearRecords();
  }
}
