import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/domain/use_cases/depa_restant/get_depa_restant_by_emp_id_use_case.dart';
import 'package:verby_flutter/presentation/providers/reposiory/depa_restant_local_repo_provider.dart';

final getDepaRestantByEmpIdProvider = Provider<GetDepaRestantByEmpIdUseCase>((
  ref,
) {
  final repository = ref.read(depaRestantLocalRepoProvider);
  return GetDepaRestantByEmpIdUseCase(repository);
});
