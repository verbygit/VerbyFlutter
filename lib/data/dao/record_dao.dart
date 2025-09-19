import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:verby_flutter/data/models/local/depa_restant_model.dart';
import 'package:verby_flutter/data/models/local/local_record.dart';
import 'package:verby_flutter/data/models/local/plan.dart';
import 'package:verby_flutter/data/models/remote/employee.dart';
import '../data_source/local/database_helper.dart';
import '../models/local/employee_action_state.dart';
import '../models/local/employee_performs_state.dart';
import '../models/remote/calender/depa_restant.dart';

class RecordDao {
  final DatabaseHelper _databaseHelper;

  RecordDao(this._databaseHelper);

  Future<void> insertRecord(LocalRecord localRecord) async {
    if (kDebugMode) {
      print("saves localRecord values==============> ${localRecord.toJson()}");
    }
    try {
      final db = await _databaseHelper.database;
      await db?.insert(
        DatabaseHelper.TABLE_RECORD,
        localRecord.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> insertRecords(List<LocalRecord> localRecords) async {
    final db = await _databaseHelper.database;
    if (db != null) {
      Batch batch = db.batch();

      for (var record in localRecords) {
        batch.insert(
          DatabaseHelper.TABLE_RECORD,
          record.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    }
  }

  Future<List<LocalRecord>> getAllRecord() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>>? result = await db?.query(
      DatabaseHelper.TABLE_RECORD,
    );
    return result?.map((row) => LocalRecord.fromJson(row)).toList() ?? [];
  }

  Future<bool> clearRecords() async {
    try {
      final db = await _databaseHelper.database;
      await db?.delete(DatabaseHelper.TABLE_RECORD);
      if (kDebugMode) {
        print("✅ record clear");
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error deleting  records: $e");
      }
      return false;
    }
  }
}
