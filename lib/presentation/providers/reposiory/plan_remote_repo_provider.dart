import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/data/repositories/plan_remote_repository_impl.dart';
import 'package:verby_flutter/domain/repositories/plan_remote_repository.dart';
import 'package:verby_flutter/presentation/providers/api_service_provider.dart';

final planRemoteRepoProvider = Provider<PlanRemoteRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PlanRemoteRepositoryImpl(apiService);
});
