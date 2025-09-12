import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/presentation/providers/reposiory/auth_repo_provider.dart';
import '../../../domain/use_cases/auth/login_use_case.dart';

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LoginUseCase(authRepository);
});
