import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/data/repositories/depa_restant_remote_repository_impl.dart';
import 'package:verby_flutter/data/repositories/plan_remote_repository_impl.dart';
import 'package:verby_flutter/domain/repositories/depa_restant_remote_repository.dart';
import 'package:verby_flutter/domain/repositories/plan_remote_repository.dart';
import 'package:verby_flutter/presentation/providers/api_service_provider.dart';

final depaRestantRemoteRepoProvider = Provider<DepaRestantRemoteRepository>((
  ref,
) {
  final apiService = ref.watch(apiServiceProvider);
  return DepaRestantRemoteRepositoryImpl(apiService);
});
