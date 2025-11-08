import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/domain/use_cases/record/create_multi_record_remotely__use_case.dart';
import 'package:verby_flutter/domain/use_cases/record/create_record_remotely__use_case.dart';
import 'package:verby_flutter/domain/use_cases/record/get_record_from_server_use_case.dart';
import 'package:verby_flutter/presentation/providers/reposiory/record_remote_repo_provider.dart';

final createMultiRecordRemoteUseCaseProvider =
    Provider<CreateMultiRecordRemotelyUseCase>((ref) {
      final repository = ref.watch(recordRemoteRepoProvider);
      return CreateMultiRecordRemotelyUseCase(repository);
    });
