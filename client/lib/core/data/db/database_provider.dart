import 'package:mongo_dart/mongo_dart.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();

  Db? _database;
  DateTime? timestamp;

  Future<Db> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Db> _initDb() async {
    var databasesPath = await getDatabasesPath();
  }
}
