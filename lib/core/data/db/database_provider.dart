import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._internal();
  static Database? _database;

  DatabaseProvider._internal();

  factory DatabaseProvider() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'database.db');
    await deleteDatabase(path);
    return await openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute('''
        CREATE TABLE Races(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          description TEXT,
          speed INTEGER,
          languages TEXT,
          vision TEXT,
          traits TEXT
        );

        CREATE TABLE ASI (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          race_id INTEGER,
          attribute_id INTEGER,
          value INTEGER,
          FOREIGN KEY(race_id) REFERENCES Races(id),
        );

        CREATE TABLE Subraces(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          race_id INTEGER,
          subrace_id INTEGER,
          FOREIGN KEY(race_id) REFERENCES Races(id),
          FOREIGN KEY(subrace_id) REFERENCES Races(id),
      ''');
    });
  }
}
