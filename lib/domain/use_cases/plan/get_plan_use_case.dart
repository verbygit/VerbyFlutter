import 'package:dartz/dartz.dart';
import 'package:verby_flutter/domain/repositories/auth_repository.dart';
import 'package:verby_flutter/domain/repositories/plan_remote_repository.dart';

import '../../core/failure.dart';

class GetPlanUseCase {
  final PlanRemoteRepository planRemoteRepository;

  GetPlanUseCase(this.planRemoteRepository);

  Future<Either<Failure, String>> call(
    String deviceID,
    int employeeID,
  ) async {
    return planRemoteRepository.getPlan(deviceID, employeeID);
  }
}
