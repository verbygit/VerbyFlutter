import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/remote/calender/calender_response.dart';
import '../core/failure.dart';

abstract class DepaRestantRemoteRepository {
  Future<Either<Failure, CalenderResponse>> getDepaRestants(
    String deviceID,
    int employeeId,
  );
}
