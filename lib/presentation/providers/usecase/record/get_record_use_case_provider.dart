import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/domain/use_cases/record/get_record_from_server_use_case.dart';
import 'package:verby_flutter/presentation/providers/reposiory/record_remote_repo_provider.dart';

final getRecordUseCaseProvider = Provider<GetRecordFromServerUseCase>((ref) {
  final repository = ref.watch(recordRemoteRepoProvider);
  return GetRecordFromServerUseCase(repository);
});
