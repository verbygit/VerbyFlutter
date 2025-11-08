import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/local/employee_performs_state.dart';
import 'package:verby_flutter/data/models/local/plan.dart';
import 'package:verby_flutter/data/models/remote/employee_list_response.dart';
import 'package:verby_flutter/domain/repositories/employee_local_repository.dart';
import 'package:verby_flutter/domain/repositories/employee_remote_repository.dart';
import 'package:verby_flutter/domain/repositories/plan_local_repository.dart';

import '../../core/failure.dart';

class GetPlanByEmpIdUseCase {
  final PlanLocalRepository repository;

  GetPlanByEmpIdUseCase(this.repository);

  Future<Either<String, Plan>> call(String id) async {
    return await repository.getPlanByEmployeeId(id);
  }
}
