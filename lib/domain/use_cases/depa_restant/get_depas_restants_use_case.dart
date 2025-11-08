import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/remote/calender/calender_response.dart';
import 'package:verby_flutter/domain/repositories/auth_repository.dart';
import 'package:verby_flutter/domain/repositories/depa_restant_remote_repository.dart';
import 'package:verby_flutter/domain/repositories/plan_remote_repository.dart';

import '../../core/failure.dart';

class GetDepaRestantsUseCase {
  final DepaRestantRemoteRepository repository;

  GetDepaRestantsUseCase(this.repository);

  Future<Either<Failure, CalenderResponse>> call(
    String deviceID,
    int employeeID,
  ) async {
    return repository.getDepaRestants(deviceID, employeeID);
  }
}
