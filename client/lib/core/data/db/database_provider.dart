import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static Future<void> purgeDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'database.db');
    await deleteDatabase(path);
  }

  Future<Database> _initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'database.db');
    await deleteDatabase(path);
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
      CREATE TABLE Feats(
        slug TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        prerequisite TEXT,
        effects_desc TEXT,
        document_title TEXT
      );
    ''');
      await db.execute('''
      CREATE TABLE Races(
        slug TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        speed INTEGER,
        languages TEXT,
        vision TEXT,
        traits TEXT,
        asi TEXT
      );
    ''');
      await db.execute('''
      CREATE TABLE Characters(
        name TEXT PRIMARY KEY,
        race_slug TEXT,
        FOREIGN KEY (race_slug) REFERENCES Races(slug)
      );
    ''');
    });
  }
}
