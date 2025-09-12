import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/domain/use_cases/depa_restant/get_local_depa_restant_usecase.dart';
import 'package:verby_flutter/presentation/providers/reposiory/depa_restant_local_repo_provider.dart';

final getLocalDepaRestantProvider = Provider<GetLocalDepaRestantUsecase>((ref) {
  final repository = ref.watch(depaRestantLocalRepoProvider);
  return GetLocalDepaRestantUsecase(repository);
});
