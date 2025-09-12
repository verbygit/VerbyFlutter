import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:verby_flutter/data/models/local/face_model.dart';
import '../data_source/local/database_helper.dart';

class FaceDao {
  final DatabaseHelper _databaseHelper;

  FaceDao(this._databaseHelper);

  /// Insert a new face record
  Future<void> insertFace(FaceModel face) async {
    if (kDebugMode) {
      print("💾 Saving face to database: ${face.toJson()}");
    }
    try {
      final db = await _databaseHelper.database;
      await db?.insert(
        DatabaseHelper.TABLE_FACE,
        face.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (kDebugMode) {
        print("✅ Face saved successfully for employee: ${face.employeeId}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error saving face: $e");
      }
      rethrow;
    }
  }

  /// Insert multiple face records in batch
  Future<void> insertFaces(List<FaceModel> faces) async {
    final db = await _databaseHelper.database;
    if (db != null) {
      Batch batch = db.batch();

      for (var face in faces) {
        batch.insert(
          DatabaseHelper.TABLE_FACE,
          face.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
      if (kDebugMode) {
        print("✅ Batch inserted ${faces.length} faces");
      }
    }
  }

  /// Get face by employee ID (primary key)
  Future<FaceModel?> getFaceByEmployeeId(String employeeId) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>>? result = await db?.query(
        DatabaseHelper.TABLE_FACE,
        where: 'employee_id = ?',
        whereArgs: [employeeId],
        limit: 1,
      );

      if (result != null && result.isNotEmpty) {
        return FaceModel.fromJson(result.first);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error getting face by employee ID: $e");
      }
      return null;
    }
  }

  /// Get face by employee ID (same as getFaceByEmployeeId for consistency)
  Future<FaceModel?> getFaceById(String employeeId) async {
    return getFaceByEmployeeId(employeeId);
  }

  /// Get all faces
  Future<List<FaceModel>> getAllFaces() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>>? result = await db?.query(
        DatabaseHelper.TABLE_FACE,
        orderBy: 'registered_at DESC',
      );
      return result?.map((row) => FaceModel.fromJson(row)).toList() ?? [];
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error getting all faces: $e");
      }
      return [];
    }
  }

  /// Get all active faces
  Future<List<FaceModel>> getActiveFaces() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>>? result = await db?.query(
        DatabaseHelper.TABLE_FACE,
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: 'registered_at DESC',
      );
      return result?.map((row) => FaceModel.fromJson(row)).toList() ?? [];
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error getting active faces: $e");
      }
      return [];
    }
  }

  /// Update face record
  Future<void> updateFace(FaceModel face) async {
    try {
      final db = await _databaseHelper.database;
      await db?.update(
        DatabaseHelper.TABLE_FACE,
        face.toJson(),
        where: 'employee_id = ?',
        whereArgs: [face.employeeId],
      );
      if (kDebugMode) {
        print("✅ Face updated successfully: ${face.employeeId}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error updating face: $e");
      }
      rethrow;
    }
  }

  /// Update last used timestamp
  Future<void> updateLastUsed(String employeeId) async {
    try {
      final db = await _databaseHelper.database;
      await db?.update(
        DatabaseHelper.TABLE_FACE,
        {'last_used_at': DateTime.now().toIso8601String()},
        where: 'employee_id = ?',
        whereArgs: [employeeId],
      );
      if (kDebugMode) {
        print("✅ Last used timestamp updated for employee: $employeeId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error updating last used timestamp: $e");
      }
    }
  }

  /// Deactivate face (soft delete)
  Future<void> deactivateFace(String employeeId) async {
    try {
      final db = await _databaseHelper.database;
      await db?.update(
        DatabaseHelper.TABLE_FACE,
        {'is_active': 0},
        where: 'employee_id = ?',
        whereArgs: [employeeId],
      );
      if (kDebugMode) {
        print("✅ Face deactivated for employee: $employeeId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error deactivating face: $e");
      }
      rethrow;
    }
  }

  /// Permanently delete face record
  Future<void> deleteFace(String employeeId) async {
    try {
      final db = await _databaseHelper.database;
      await db?.delete(
        DatabaseHelper.TABLE_FACE,
        where: 'employee_id = ?',
        whereArgs: [employeeId],
      );
      if (kDebugMode) {
        print("✅ Face deleted permanently for employee: $employeeId");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error deleting face: $e");
      }
      rethrow;
    }
  }

  /// Check if face exists for employee
  Future<bool> faceExists(String employeeId) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db?.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.TABLE_FACE} WHERE employee_id = ?',
        [employeeId],
      );
      return ((result?.first['count'] as int?) ?? 0) > 0;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error checking if face exists: $e");
      }
      return false;
    }
  }

  /// Get face count
  Future<int> getFaceCount() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db?.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.TABLE_FACE}',
      );
      return (result?.first['count'] as int?) ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error getting face count: $e");
      }
      return 0;
    }
  }

  /// Get active face count
  Future<int> getActiveFaceCount() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db?.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.TABLE_FACE} WHERE is_active = 1',
      );
      return (result?.first['count'] as int?) ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error getting active face count: $e");
      }
      return 0;
    }
  }

  /// Delete all faces (for debug purposes)
  Future<void> deleteAllFaces() async {
    try {
      final db = await _databaseHelper.database;
      await db?.delete(DatabaseHelper.TABLE_FACE);
      if (kDebugMode) {
        print("✅ All faces deleted successfully");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error deleting all faces: $e");
      }
      rethrow;
    }
  }
}
