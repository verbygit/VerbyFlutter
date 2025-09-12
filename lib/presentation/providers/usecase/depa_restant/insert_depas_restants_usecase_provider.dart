import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/domain/use_cases/depa_restant/insert_depas_restants_use_case.dart';
import 'package:verby_flutter/domain/use_cases/plan/get_local_plan_usecase.dart';
import 'package:verby_flutter/domain/use_cases/plan/insert_plans_use_case.dart';
import 'package:verby_flutter/presentation/providers/reposiory/depa_restant_local_repo_provider.dart';
import 'package:verby_flutter/presentation/providers/reposiory/plan_local_repo_provider.dart';

final insertDepaRestantsUseCaseProvider = Provider<InsertDepaRestantsUseCase>((
  ref,
) {
  final repository = ref.watch(depaRestantLocalRepoProvider);
  return InsertDepaRestantsUseCase(repository);
});
