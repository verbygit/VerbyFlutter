import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:verby_flutter/data/dao/depa_restant_dao.dart';
import 'package:verby_flutter/data/models/local/depa_restant_model.dart';
import 'package:verby_flutter/domain/repositories/depa_restant_local_repository.dart';

class DepaRestantLocalRepositoryImpl extends DepaRestantLocalRepository {
  final DepaRestantDao depaRestantDao;

  DepaRestantLocalRepositoryImpl(this.depaRestantDao);

  @override
  Future<bool> insetDepaRestants(List<DepaRestantModel> depaRestants) async {
    try {
      await depaRestantDao.insertDepaRestants(depaRestants);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  @override
  Future<Either<String, List<DepaRestantModel>>> getDepaRestants(
    bool isDepa,
  ) async {
    try {
      var result = await depaRestantDao.getAllDepaRestants(isDepa);
      return Right(result);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<DepaRestantModel>?>> getDepaRestantByEmployeeId(
    String id,
    bool isDepa,
  ) async {
    try {
      final result = await depaRestantDao.getDepaRestantByEmployeeId(
        id,
        isDepa,
      );

      return Right(result);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return left(e.toString());
    }
  }

  @override
  Future<bool> deleteDepaRestants(List<String> roomId) {
    return depaRestantDao.deleteDepaRestants(roomId);
  }

  @override
  Future<bool> deleteDepaRestantsByEmpId(String empId) {
    return depaRestantDao.deleteDepaRestantsByEmployeeId(empId);
  }
}
