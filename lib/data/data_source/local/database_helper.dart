import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DatabaseHelper {
  static const _databaseName = 'verby.db';
  static const _databaseVersion = 3;
  static const TABLE_EMPLOYEE = "employee";
  static const TABLE_RECORD = "records";
  static const TABLE_FACE = "faces";
  static const TABLE_EMPLOYEE_PERFORM_STATE = "employee_perform_state";
  static const TABLE_EMPLOYEE_ACTION_STATE = "employee_action_state";
  static const TABLE_PLAN = "plan";
  static const TABLE_DEPA_RESTANT = "depa_restant";

  static Future<Database?>? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }

    _database = openDatabase(
      path.join(await getDatabasesPath(), _databaseName),
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return _database;
  }

  void setDBNull() {
    _database = null;
  }

  static void _onCreate(Database db, int version) async {
    // Create employee table
    await db.execute('''
    CREATE TABLE $TABLE_RECORD (
      id INTEGER PRIMARY KEY ,
      employee INTEGER NOT NULL,  
      device INTEGER NOT NULL,  
      action INTEGER NOT NULL,  
      perform INTEGER NOT NULL,  
      identity INTEGER NOT NULL,  
      time TEXT NOT NULL,  
      depa TEXT ,  
      restant TEXT 
    )
  ''');

    // Create record table
    await db.execute('''
    CREATE TABLE $TABLE_EMPLOYEE (
      id INTEGER PRIMARY KEY ,
      name TEXT NOT NULL,  
      surname TEXT NOT NULL,  
      role INTEGER NOT NULL,  
      api_monitoring INTEGER NOT NULL,  
      pin TEXT NOT NULL,  
      fullname TEXT NOT NULL
    )
  ''');

    // Create face table
    await db.execute('''
    CREATE TABLE $TABLE_FACE (
      employee_id TEXT PRIMARY KEY,
      employee_name TEXT NOT NULL,
      face_embedding TEXT NOT NULL,
      registered_at TEXT NOT NULL,
      last_used_at TEXT NOT NULL,
      confidence_threshold REAL NOT NULL DEFAULT 0.6,
      is_active INTEGER NOT NULL DEFAULT 1,
      face_orientation TEXT,
      metadata TEXT NOT NULL DEFAULT '{}'
    )
  ''');
    // Create depa restant   table

    await db.execute('''
      CREATE TABLE $TABLE_DEPA_RESTANT (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category INTEGER,
        extra INTEGER,
        employeeId TEXT,
        isDepa INTEGER,
        status INTEGER,
        volunteer INTEGER
      )
    ''');
    await db.execute('''
  CREATE INDEX idx_employee_id ON $TABLE_DEPA_RESTANT (employeeId)
''');
    // Create employee action state table
    await db.execute('''
    CREATE TABLE $TABLE_EMPLOYEE_ACTION_STATE (
      id TEXT PRIMARY KEY,
      hadAPause BOOLEAN NOT NULL,
      checkedIn BOOLEAN NOT NULL,
      checkedOut BOOLEAN NOT NULL,
      pausedIn BOOLEAN NOT NULL,
      pausedOut BOOLEAN NOT NULL,
      lastActionTime TEXT NOT NULL,
      checkInTime TEXT NOT NULL
    )
  ''');

    // Create employee perform state table
    await db.execute('''
    CREATE TABLE $TABLE_EMPLOYEE_PERFORM_STATE (
      id TEXT PRIMARY KEY,
      isStewarding BOOLEAN NOT NULL,
      isMaintenance BOOLEAN NOT NULL,
      isRoomControl BOOLEAN NOT NULL,
      isRoomCleaning BOOLEAN NOT NULL,
      isBuro BOOLEAN NOT NULL
    )
  ''');
    // Create employee  plan table
    await db.execute('''
    CREATE TABLE $TABLE_PLAN (
      employeeId TEXT PRIMARY KEY,
      time TEXT NOT NULL
    )
  ''');
  }
  Future<bool> clearAllTablesExcept() async {
    final db = await database;
    try {
      await db?.transaction((txn) async {
        // Step 1: Query all table names (SQLite master table)
        final List<Map<String, dynamic>> tablesResult = await txn.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';"
        );

        // Filter out excepted tables
        final List<String> tablesToClear = tablesResult
            .map((row) => row['name'] as String)
            .toList();

        if (tablesToClear.isEmpty) return;  // Nothing to clear

        // Step 2: Batch DELETE for efficiency (no WHERE = delete all rows)
        final Batch batch = txn.batch();
        for (final tableName in tablesToClear) {
          batch.rawDelete('DELETE FROM $tableName');
        }
        await batch.commit(noResult: true);  // Commit without checking row counts for speed
        print('Cleared ${tablesToClear.length} tables successfully.');

      });

      // Optional: Reclaim space
      await db?.rawQuery('VACUUM;');

      return true;
    } catch (e) {
      print('Error clearing tables: $e');
      return false;
    }
  }
  static void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // For development phase - no migration needed, fresh install will handle it
    print('ℹ️ Database version upgraded from $oldVersion to $newVersion');
  }
}
