import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:verby_flutter/data/models/local/depa_restant_model.dart';
import 'package:verby_flutter/data/models/local/plan.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import '../data_source/local/database_helper.dart';
import '../models/local/employee_action_state.dart';
import '../models/local/employee_performs_state.dart';
import '../models/remote/calender/depa_restant.dart';

class DepaRestantDao {
  final DatabaseHelper _databaseHelper;

  DepaRestantDao(this._databaseHelper);

  Future<void> insertDepaRestant(DepaRestantModel depaRestant) async {
    if (kDebugMode) {
      print("saves DepaRestant values==============> ${depaRestant.toJson()}");
    }
    try {
      final db = await _databaseHelper.database;
      await db?.insert(
        DatabaseHelper.TABLE_DEPA_RESTANT,
        depaRestant.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> insertDepaRestants(List<DepaRestantModel> plans) async {
    final db = await _databaseHelper.database;
    if (db != null) {
      Batch batch = db.batch();

      for (var plan in plans) {
        batch.insert(
          DatabaseHelper.TABLE_DEPA_RESTANT,
          plan.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    }
  }

  Future<List<DepaRestantModel>> getAllDepaRestants(bool isDepa) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>>? result = await db?.query(
      DatabaseHelper.TABLE_DEPA_RESTANT,
      where: 'isDepa = ?',
      whereArgs: [isDepa],
    );
    return result?.map((row) => DepaRestantModel.fromJson(row)).toList() ?? [];
  }

  Future<List<DepaRestantModel>?> getDepaRestantByEmployeeId(
    String id,
    bool isDepa,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>>? result = await db?.query(
      DatabaseHelper.TABLE_DEPA_RESTANT,
      where: 'employeeId = ? AND isDepa = ?',
      whereArgs: [id, isDepa],
    );

    if (result != null && result.isNotEmpty) {
      return result.map((item) => DepaRestantModel.fromJson(item)).toList();
    } else {
      return null;
    }
  }

  Future<bool> deleteDepaRestants(List<String> roomId) async {
    if (roomId.isEmpty) {
      if (kDebugMode) {
        print("⚠️ No employee IDs provided for deletion.");
      }
      return true;
    }

    try {
      final db = await _databaseHelper.database;
      final placeholders = List.filled(roomId.length, '?').join(',');
      await db?.delete(
        DatabaseHelper.TABLE_DEPA_RESTANT,
        where: 'id IN ($placeholders)',
        whereArgs: roomId,
      );
      if (kDebugMode) {
        print(
          "✅ Emp action states deleted permanently for employees: ${roomId.join(', ')}",
        );
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error deleting emp action states: $e");
      }
      return false;
    }
  }
}
