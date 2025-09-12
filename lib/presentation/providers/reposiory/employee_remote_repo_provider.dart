import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/data/repositories/auth_repository_impl.dart';
import 'package:verby_flutter/data/repositories/employee_remote_repository_impl.dart';
import 'package:verby_flutter/domain/repositories/auth_repository.dart';
import 'package:verby_flutter/domain/repositories/employee_remote_repository.dart';
import 'package:verby_flutter/presentation/providers/api_service_provider.dart';

final employeeRepositoryProvider = Provider<EmployeeRemoteRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return EmployeeRemoteRepositoryImpl(apiService);
});
