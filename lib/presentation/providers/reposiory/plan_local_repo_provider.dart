import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/data/dao/employee_dao.dart';
import 'package:verby_flutter/data/dao/plan_dao.dart';
import 'package:verby_flutter/data/data_source/local/database_helper.dart';
import 'package:verby_flutter/data/repositories/plan_local_repository_impl.dart';
import 'package:verby_flutter/domain/repositories/employee_local_repository.dart';
import 'package:verby_flutter/domain/repositories/plan_local_repository.dart';
import 'package:verby_flutter/presentation/providers/api_service_provider.dart';

import '../../../data/repositories/employee_local_repository_impl.dart';

final planLocalRepoProvider = Provider<PlanLocalRepository>((ref) {
  return PlanLocalRepositoryImpl(PlanDao(DatabaseHelper()));
});
