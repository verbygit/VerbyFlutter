import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import '../data_source/local/database_helper.dart';
import '../models/local/employee_action_state.dart';
import '../models/local/employee_performs_state.dart';

class EmployeeDao {
  final DatabaseHelper _databaseHelper;

  EmployeeDao(this._databaseHelper);

  Future<void> insertEmployee(Employee question) async {
    if (kDebugMode) {
      print("saves employee values==============> ${question.toJson()}");
    }
    try {
      final db = await _databaseHelper.database;
      await db?.insert(
        DatabaseHelper.TABLE_EMPLOYEE,
        question.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> insertEmployees(List<Employee> employees) async {
    final db = await _databaseHelper.database;
    if (db != null) {
      Batch batch = db.batch();

      for (var employee in employees) {
        batch.insert(
          DatabaseHelper.TABLE_EMPLOYEE,
          employee.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    }
  }

  Future<List<Employee>> getAllEmployees() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>>? result = await db?.query(
      DatabaseHelper.TABLE_EMPLOYEE,
    );
    return result?.map((row) => Employee.fromJson(row)).toList() ?? [];
  }

  Future<bool> insertEmployeePerformState(
    EmployeePerformState employeePerformState,
  ) async {
    try {
      final db = await _databaseHelper.database;
      await db?.insert(
        DatabaseHelper.TABLE_EMPLOYEE_PERFORM_STATE,
        employeePerformState.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }


  Future<void> insertEmployeePerformStates(List<EmployeePerformState> employeePerformStates) async {
    final db = await _databaseHelper.database;
    if (db != null) {
      Batch batch = db.batch();

      for (var performState in employeePerformStates) {
        batch.insert(
          DatabaseHelper.TABLE_EMPLOYEE_PERFORM_STATE,
          performState.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    }
  }

  Future<List<EmployeePerformState>> getAllEmployeePerformStates() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>>? result = await db?.query(
      DatabaseHelper.TABLE_EMPLOYEE_PERFORM_STATE,
    );
    return result?.map((row) => EmployeePerformState.fromJson(row)).toList() ??
        [];
  }

  Future<EmployeePerformState?> getEmployeePerformStateById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>>? result = await db?.query(
      DatabaseHelper.TABLE_EMPLOYEE_PERFORM_STATE,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result != null && result.isNotEmpty) {
      return EmployeePerformState.fromJson(result.first);
    } else {
      return null;
    }
  }

  Future<bool> insertEmployeeActionState(
    EmployeeActionState employeeActionState,
  ) async {
    try {
      final db = await _databaseHelper.database;
      await db?.insert(
        DatabaseHelper.TABLE_EMPLOYEE_ACTION_STATE,
        employeeActionState.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  Future<void> insertEmployeeActionStates(List<EmployeeActionState> employeeActionStates) async {
    final db = await _databaseHelper.database;
    if (db != null) {
      Batch batch = db.batch();

      for (var actionState in employeeActionStates) {
        batch.insert(
          DatabaseHelper.TABLE_EMPLOYEE_ACTION_STATE,
          actionState.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    }
  }
  Future<List<EmployeeActionState>> getAllEmployeeActionStates() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>>? result = await db?.query(
      DatabaseHelper.TABLE_EMPLOYEE_ACTION_STATE,
    );
    return result?.map((row) => EmployeeActionState.fromJson(row)).toList() ??
        [];
  }

  Future<EmployeeActionState?> getEmployeeActionStateById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>>? result = await db?.query(
      DatabaseHelper.TABLE_EMPLOYEE_ACTION_STATE,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result != null && result.isNotEmpty) {
      return EmployeeActionState.fromJson(result.first);
    } else {
      return null;
    }
  }

  Future<bool> deleteEmpPerformanceState(String employeeId) async {
    try {
      final db = await _databaseHelper.database;
      await db?.delete(
        DatabaseHelper.TABLE_EMPLOYEE_PERFORM_STATE,
        where: 'id = ?',
        whereArgs: [employeeId],
      );
      if (kDebugMode) {
        print(
          "✅ Emp performance state deleted permanently for employee: $employeeId",
        );
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error deleting emp performance state: $e");
      }
      return false;
    }
  }

  Future<bool> deleteEmpActionState(String employeeId) async {
    try {
      final db = await _databaseHelper.database;
      await db?.delete(
        DatabaseHelper.TABLE_EMPLOYEE_ACTION_STATE,
        where: 'id = ?',
        whereArgs: [employeeId],
      );
      if (kDebugMode) {
        print(
          "✅ Emp action state deleted permanently for employee: $employeeId",
        );
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error deleting emp action state: $e");
      }
      return false;
    }
  }

  Future<bool> deleteAppDatabase() async {
    String databasePath = await getDatabasesPath();
    String dbPath = join(databasePath, 'x_puzzle.db');
    await deleteDatabase(dbPath);
    _databaseHelper.setDBNull();
    return true;
  }
}
