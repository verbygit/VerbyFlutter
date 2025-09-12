import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/local/plan.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/data/models/remote/employee_list_response.dart';
import 'package:verby_flutter/domain/repositories/employee_local_repository.dart';
import 'package:verby_flutter/domain/repositories/employee_remote_repository.dart';
import 'package:verby_flutter/domain/repositories/plan_local_repository.dart';

import '../../core/failure.dart';

class GetLocalPlansUseCase {
  final PlanLocalRepository _repository;

  GetLocalPlansUseCase(this._repository);

  Future<Either<String, List<Plan>>> call() async {
    return await _repository.getPlans();
  }
}
