// import 'package:flutter/foundation.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:xpuzzle/data/models/local/question_model.dart';
//
// import '../../domain/entities/question.dart';
// import '../data_source/local/database_helper.dart';
//
// class QuestionDao {
//   final DatabaseHelper _databaseHelper;
//
//   QuestionDao(this._databaseHelper);
//
//   Future<List<Question>> getAllQuestions({
//     bool isPPAndPS = false,
//     bool isPPAndNS = false,
//     bool isNPAndPS = false,
//     bool isNPAndNS = false,
//     bool isComplete = false,
//   }) async {
//     try {
//       final db = await _databaseHelper.database;
//       final result = await db?.query('question',
//           where:
//               'is_pp_and_ps=? AND is_pp_and_ns=? AND is_np_and_ns=? AND is_np_and_ps=? AND is_complete=?',
//           whereArgs: [
//             isPPAndPS ? 1 : 0,
//             isPPAndNS ? 1 : 0,
//             isNPAndNS ? 1 : 0,
//             isNPAndPS ? 1 : 0,
//             isComplete ? 1 : 0
//           ]);
//       if (kDebugMode) {
//         print("saves question values==============> ${result.toString()}");
//       }
//
//       return result?.map((row) => QuestionModel.fromJson(row)).toList() ?? [];
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//       return [];
//     }
//   }
//
//   Future<void> insertQuestion(QuestionModel question) async {
//     if (kDebugMode) {
//       print("saves question values==============> ${question.toJson()}");
//     }
//     try {
//       final db = await _databaseHelper.database;
//       await db?.insert(
//         DatabaseHelper.TABLE_QUESTION,
//         question.toJson(),
//         conflictAlgorithm: ConflictAlgorithm.replace,
//       );
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//     }
//   }
//
//   Future<void> updateQuestion(Question question) async {
//     QuestionModel questionModel = QuestionModel.copy(question);
//     if (kDebugMode) {
//       print("updateQuestion==============> ${questionModel.toJson()}");
//     }
//     try {
//       final db = await _databaseHelper.database;
//       await db?.update(
//         DatabaseHelper.TABLE_QUESTION,
//         questionModel.toJson(),
//         where: 'id = ?',
//         whereArgs: [questionModel.id],
//         conflictAlgorithm: ConflictAlgorithm.replace,
//       );
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//     }
//   }
//
//   Future<bool> checkIfIsPPAndPSExists() async {
//     final db = await _databaseHelper.database;
//     var result = await db?.query(DatabaseHelper.TABLE_QUESTION,
//         where: 'is_pp_and_ps = ?', whereArgs: [1], limit: 1);
//
//     return result?.isNotEmpty ?? false;
//   }
//
//   Future<bool> checkIfIsPPAndNSExists() async {
//     final db = await _databaseHelper.database;
//     var result = await db?.query(DatabaseHelper.TABLE_QUESTION,
//         where: 'is_pp_and_ns = ?', whereArgs: [1], limit: 1);
//
//     return result?.isNotEmpty ?? false;
//   }
//
//   Future<bool> checkIfIsNPAndPSExists() async {
//     final db = await _databaseHelper.database;
//     var result = await db?.query(DatabaseHelper.TABLE_QUESTION,
//         where: 'is_np_and_ps = ?', whereArgs: [1], limit: 1);
//
//     return result?.isNotEmpty ?? false;
//   }
//
//   Future<bool> checkIfIsNPAndNSExists() async {
//     final db = await _databaseHelper.database;
//     var result = await db?.query(DatabaseHelper.TABLE_QUESTION,
//         where: 'is_np_and_ns = ?', whereArgs: [1], limit: 1);
//
//     return result?.isNotEmpty ?? false;
//   }
//
//   Future<void> deleteEntry({
//     bool isPPAndPS = false,
//     bool isPPAndNS = false,
//     bool isNPAndPS = false,
//     bool isNPAndNS = false,
//     bool isComplete = true,
//   }) async {
//     final db = await _databaseHelper.database;
//
//     if (kDebugMode) {
//       print(
//           "questions deleted:${isPPAndPS ? 1 : 0}, ${isPPAndNS ? 1 : 0}, ${isNPAndNS ? 1 : 0},${isNPAndPS ? 1 : 0},${isComplete ? 1 : 0} ");
//     }
//     await db?.delete(
//       DatabaseHelper.TABLE_QUESTION,
//       where:
//           'is_pp_and_ps=? AND is_pp_and_ns=? AND is_np_and_ns=? AND is_np_and_ps=? AND is_complete=?',
//       whereArgs: [
//         isPPAndPS ? 1 : 0,
//         isPPAndNS ? 1 : 0,
//         isNPAndNS ? 1 : 0,
//         isNPAndPS ? 1 : 0,
//         isComplete ? 1 : 0
//       ],
//     );
//   }
//
//   Future<bool> deleteAppDatabase() async {
//     String databasePath = await getDatabasesPath();
//     String dbPath = join(databasePath, 'x_puzzle.db');
//
//     try {
//       await deleteDatabase(dbPath);
//       _databaseHelper.setDBNull();
//       return true;
//     } catch (e) {
//       if (kDebugMode) {
//         print(e.toString());
//       }
//       return false;
//     }
//   }
// }
