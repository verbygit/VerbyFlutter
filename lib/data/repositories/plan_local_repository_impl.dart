import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:verby_flutter/data/dao/employee_dao.dart';
import 'package:verby_flutter/data/dao/plan_dao.dart';
import 'package:verby_flutter/data/models/local/employee_action_state.dart';
import 'package:verby_flutter/data/models/local/employee_performs_state.dart';
import 'package:verby_flutter/data/models/local/plan.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/domain/repositories/employee_local_repository.dart';
import 'package:verby_flutter/domain/repositories/plan_local_repository.dart';

class PlanLocalRepositoryImpl extends PlanLocalRepository {
  final PlanDao planDao;

  PlanLocalRepositoryImpl(this.planDao);

  @override
  Future<bool> insetPlans(List<Plan> employees) async {
    try {
      await planDao.insertPlans(employees);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  @override
  Future<Either<String, List<Plan>>> getPlans() async {
    try {
      var result = await planDao.getAllPlans();
      return Right(result);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Plan>> getPlanByEmployeeId(String id) async {
    try {
      final result = await planDao.getPlanByEmployeeId(id);

      if (result!=null) {
        return Right(result);
      }else{
        return Left("not found");

      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return Left(e.toString());
    }
  }
}
