import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:verby_flutter/data/data_source/remote/api_client.dart';
import 'package:verby_flutter/data/models/remote/calender/calender_response.dart';
import 'package:verby_flutter/domain/core/failure.dart';
import 'package:verby_flutter/domain/repositories/depa_restant_remote_repository.dart';

import '../../core/api_constant.dart';

class DepaRestantRemoteRepositoryImpl extends DepaRestantRemoteRepository {
  final ApiClient apiClient;

  DepaRestantRemoteRepositoryImpl(this.apiClient);

  String _getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    final formattedDate = formatter.format(now);
    return formattedDate;
  }

  @override
  Future<Either<Failure, CalenderResponse>> getDepaRestants(
    String deviceID,
    int employeeId,
  ) {
    return apiClient.get(
      ApiConstant.calendar(deviceID),
      queryParameters: {"employee": employeeId, "date": _getCurrentDate()},
      fromJson: (data) => CalenderResponse.fromJson(data),
    );
  }
}
