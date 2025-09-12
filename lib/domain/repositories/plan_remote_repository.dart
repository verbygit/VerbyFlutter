import 'package:dartz/dartz.dart';

import '../core/failure.dart';

abstract class PlanRemoteRepository {
  Future<Either<Failure, String>> getPlan(String deviceID, int employeeId);
}
