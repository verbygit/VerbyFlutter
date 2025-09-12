import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/local/employee_performs_state.dart';
import 'package:verby_flutter/data/models/local/plan.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';

import '../../data/models/local/employee_action_state.dart';

abstract class PlanLocalRepository {
  Future<void> insetPlans(List<Plan> employees);

  Future<Either<String, List<Plan>>> getPlans();

  Future<Either<String, Plan?>> getPlanByEmployeeId(String id);
}
