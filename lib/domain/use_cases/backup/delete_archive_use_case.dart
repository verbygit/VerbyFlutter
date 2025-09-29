import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/service/backup_service.dart';

class DeleteArchiveUseCase {
  final BackupService _backupService;

  DeleteArchiveUseCase(this._backupService);

  Future<Either<String, bool>> call() async {
    return await _backupService.deleteOriginalAndroidFile();
  }
}
