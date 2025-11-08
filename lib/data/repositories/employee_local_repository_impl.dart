import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:verby_flutter/data/dao/employee_dao.dart';
import 'package:verby_flutter/data/models/local/employee_action_state.dart';
import 'package:verby_flutter/data/models/local/employee_performs_state.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import 'package:verby_flutter/domain/repositories/employee_local_repository.dart';

class EmployeeLocalRepositoryImpl extends EmployeeLocalRepository {
  final EmployeeDao employeeDao;

  EmployeeLocalRepositoryImpl(this.employeeDao);

  @override
  Future<void> insetEmployees(List<Employee> employees) async {
    try {
      await employeeDao.insertEmployees(employees);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Future<Either<String, List<Employee>>> getEmployees() async {
    try {
      var result = await employeeDao.getAllEmployees();
      return Right(result);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return Left(e.toString());
    }
  }

  @override
  Future<bool> insetEmployeePerformState(
    EmployeePerformState employeePerformState,
  ) async {
    try {
      return await employeeDao.insertEmployeePerformState(employeePerformState);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  @override
  Future<Either<String, EmployeePerformState?>> getEmployeePerformStateById(
    String id,
  ) async {
    try {
      final result = await employeeDao.getEmployeePerformStateById(id);

      return Right(result);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return left(e.toString());
    }
  }

  @override
  Future<bool> insetEmployeeActionState(
    EmployeeActionState employeeActionState,
  ) async {
    try {
      return await employeeDao.insertEmployeeActionState(employeeActionState);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  @override
  Future<Either<String, EmployeeActionState?>> getEmployeeActionStateById(
    String id,
  ) async {
    try {
      final result = await employeeDao.getEmployeeActionStateById(id);

      return Right(result);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, List<EmployeeActionState>>>
  getEmployeeActionState() async {
    try {
      var result = await employeeDao.getAllEmployeeActionStates();
      return Right(result);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<EmployeePerformState>>>
  getEmployeePerformState() async {
    try {
      var result = await employeeDao.getAllEmployeePerformStates();
      return Right(result);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return Left(e.toString());
    }
  }

  @override
  Future<bool> deleteEmpActionState(String employeeId) {
    return employeeDao.deleteEmpActionState(employeeId);
  }

  @override
  Future<bool> deleteEmpPerformanceState(String employeeId) {
    return employeeDao.deleteEmpPerformanceState(employeeId);
  }

  @override
  Future<bool> insetEmployeeActionStates(
    List<EmployeeActionState> employeeActionStates,
  ) async {
    try {
      await employeeDao.insertEmployeeActionStates(employeeActionStates);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  @override
  Future<bool> insetEmployeePerformStates(
    List<EmployeePerformState> employeePerformStates,
  ) async {
    try {
      await employeeDao.insertEmployeePerformStates(employeePerformStates);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;

    }
  }
}
