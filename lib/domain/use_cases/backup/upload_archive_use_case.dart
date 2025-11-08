import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:verby_flutter/data/models/remote/record/CreateRecordRequest.dart';
import 'package:verby_flutter/data/service/backup_service.dart';
import 'package:verby_flutter/domain/core/failure.dart';

class UploadArchiveUseCase {
  final BackupService _backupService;

  UploadArchiveUseCase(this._backupService);

  Future<Either<String, List<CreateRecordRequest>>> call() async {
    try {
      final List<CreateRecordRequest>? records = await _backupService
          .uploadAndExtractRecords();

      if (records != null && records.isNotEmpty) {
        return Right(records);
      } else {
        return Left('archive_extraction_failed'.tr());
      }
    } catch (e) {
      return Left('Error processing archive: $e');
    }
  }
}
