import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/data/service/backup_service.dart';
import 'package:verby_flutter/domain/use_cases/backup/delete_archive_use_case.dart';
import 'package:verby_flutter/domain/use_cases/backup/upload_archive_use_case.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});

final uploadArchiveUseCaseProvider = Provider<UploadArchiveUseCase>((ref) {
  final backupService = ref.read(backupServiceProvider);
  return UploadArchiveUseCase(backupService);
});

final deleteArchiveUseCaseProvider = Provider<DeleteArchiveUseCase>((ref) {
  final backupService = ref.read(backupServiceProvider);
  return DeleteArchiveUseCase(backupService);
});
