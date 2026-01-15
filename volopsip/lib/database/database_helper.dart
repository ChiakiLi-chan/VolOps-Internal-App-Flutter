import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // === Initialize FFI for desktop ===
    sqfliteFfiInit(); // initialize FFI
    databaseFactory = databaseFactoryFfi; // set global database factory

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'volopsip.db'); // single DB for all

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Volunteers table
    await db.execute('''
      CREATE TABLE volunteers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        nickname TEXT,
        age INTEGER NOT NULL,
        email TEXT NOT NULL,
        contact_number TEXT NOT NULL,
        volunteer_type TEXT NOT NULL
      )
    ''');

    // Events table
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        default_option TEXT NOT NULL,
        attributes TEXT NOT NULL
      )
    ''');

    // Join table for event assignments
    await db.execute('''
      CREATE TABLE event_volunteers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_id INTEGER NOT NULL,
        volunteer_id INTEGER NOT NULL,
        attribute TEXT NOT NULL,
        FOREIGN KEY(event_id) REFERENCES events(id),
        FOREIGN KEY(volunteer_id) REFERENCES volunteers(id)
      )
    ''');
  }
}
