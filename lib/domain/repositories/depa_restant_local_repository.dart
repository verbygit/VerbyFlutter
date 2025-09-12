import 'package:dartz/dartz.dart';
import 'package:verby_flutter/data/models/local/depa_restant_model.dart';

abstract class DepaRestantLocalRepository {
  Future<void> insetDepaRestants(List<DepaRestantModel> employees);

  Future<Either<String, List<DepaRestantModel>>> getDepaRestants(bool isDepa);

  Future<Either<String, List<DepaRestantModel>?>> getDepaRestantByEmployeeId(
    String id,
    bool isDepa,
  );
  Future<bool> deleteDepaRestants(List<String> roomId);

}
