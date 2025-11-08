import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/domain/use_cases/auth/get_device_info_use_case.dart';
import 'package:verby_flutter/presentation/providers/reposiory/auth_repo_provider.dart';
import '../../../domain/use_cases/auth/login_use_case.dart';

final getDeviceInfoUseCaseProvider = Provider<GetDeviceInfoUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return GetDeviceInfoUseCase(authRepository);
});
