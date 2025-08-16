import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DatabaseHelper {
  static const _databaseName = 'x_puzzle.db';
  static const _databaseVersion = 1;
  static const TABLE_QUESTION = "question";
  static const TABLE_QUESTION_TIME = "question_time";

  static Future<Database?>? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }

    _database = openDatabase(
      path.join(await getDatabasesPath(), _databaseName),
      version: _databaseVersion,
      onCreate: _onCreate,
    );

    return _database;
  }

  void setDBNull() {
    _database = null;
  }

  static void _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $TABLE_QUESTION (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      num_one TEXT NOT NULL,  
      num_two TEXT NOT NULL,  
      input_num_one TEXT NOT NULL,  
      input_num_two TEXT NOT NULL,  
      top_num TEXT NOT NULL,
      bottom_num TEXT NOT NULL,
      is_complete BOOLEAN DEFAULT 0,
      is_correct BOOLEAN DEFAULT 0,
      is_pp_and_ps BOOLEAN DEFAULT 0,
      is_pp_and_ns BOOLEAN DEFAULT 0,
      is_np_and_ns BOOLEAN DEFAULT 0,
      is_np_and_ps BOOLEAN DEFAULT 0
    )
  ''');

    await db.execute('''
    CREATE TABLE $TABLE_QUESTION_TIME (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      minutes INTEGER NOT NULL,  
      seconds INTEGER NOT NULL,  
      is_pp_and_ps BOOLEAN DEFAULT 0,
      is_pp_and_ns BOOLEAN DEFAULT 0,
      is_np_and_ns BOOLEAN DEFAULT 0,
      is_np_and_ps BOOLEAN DEFAULT 0
    )
  ''');
  }
}
