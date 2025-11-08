import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:verby_flutter/data/data_source/remote/api_client.dart';
import 'package:verby_flutter/domain/core/failure.dart';
import 'package:verby_flutter/domain/repositories/plan_remote_repository.dart';

import '../../core/api_constant.dart';

class PlanRemoteRepositoryImpl extends PlanRemoteRepository {
  final ApiClient apiClient;

  PlanRemoteRepositoryImpl(this.apiClient);

  @override
  Future<Either<Failure, List<String>>> getPlan(String deviceID, int employeeId) {
    return apiClient.get(
      ApiConstant.plan(deviceID),
      queryParameters: {"employee": employeeId, "date": _getCurrentDate()},
      fromJson: (data) {
        if (data is List) {
          return data.map((e) => e.toString()).toList();
        }
        throw Exception("Expected List but got ${data.runtimeType}");
      },    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    final formattedDate = formatter.format(now);
    return formattedDate;
  }
}
