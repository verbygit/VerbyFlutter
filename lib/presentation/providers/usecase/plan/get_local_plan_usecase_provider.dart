import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/domain/use_cases/plan/get_local_plan_usecase.dart';
import 'package:verby_flutter/presentation/providers/reposiory/plan_local_repo_provider.dart';

final getLocalPlanUseCase = Provider<GetLocalPlansUseCase>((ref) {
  final repository = ref.watch(planLocalRepoProvider);
  return GetLocalPlansUseCase(repository);
});
