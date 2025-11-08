import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:verby_flutter/data/models/local/plan.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import '../data_source/local/database_helper.dart';
import '../models/local/employee_action_state.dart';
import '../models/local/employee_performs_state.dart';

class PlanDao {
  final DatabaseHelper _databaseHelper;

  PlanDao(this._databaseHelper);

  Future<void> insertPlan(Plan plan) async {
    if (kDebugMode) {
      print("saves plan values==============> ${plan.toJson()}");
    }
    try {
      final db = await _databaseHelper.database;
      await db?.insert(
        DatabaseHelper.TABLE_PLAN,
        plan.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> insertPlans(List<Plan> plans) async {
    final db = await _databaseHelper.database;
    if (db != null) {
      Batch batch = db.batch();

      for (var plan in plans) {
        batch.insert(
          DatabaseHelper.TABLE_PLAN,
          plan.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    await batch.commit(noResult: true);
    }
  }

  Future<List<Plan>> getAllPlans() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>>? result = await db?.query(
      DatabaseHelper.TABLE_PLAN,
    );
    return result?.map((row) => Plan.fromJson(row)).toList() ?? [];
  }

  Future<Plan?> getPlanByEmployeeId(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>>? result = await db?.query(
      DatabaseHelper.TABLE_PLAN,
      where: 'employeeId = ?',
      whereArgs: [id],
    );

    if (result != null && result.isNotEmpty) {
      return Plan.fromJson(result.first);
    } else {
      return null;
    }
  }

}
