import 'package:firebase_database/firebase_database.dart';

class RealtimeDatabaseProvider {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  Future<DataSnapshot> readData(String path) async {
    return await _db.ref(path).get();
  }

  Future<void> writeData(String path, Map<String, dynamic> data) async {
    await _db.ref(path).set(data);
  }

  Future<void> updateData(String path, Map<String, dynamic> data) async {
    await _db.ref(path).update(data);
  }

  Future<void> deleteData(String path) async {
    await _db.ref(path).remove();
  }

  Stream<DatabaseEvent> onValueStream(String path) {
    return _db.ref(path).onValue;
  }

  Stream<DatabaseEvent> onChildAdded(String path) {
    return _db.ref(path).onChildAdded;
  }

  Stream<DatabaseEvent> onChildChanged(String path) {
    return _db.ref(path).onChildChanged;
  }

  Stream<DatabaseEvent> onChildRemoved(String path) {
    return _db.ref(path).onChildRemoved;
  }
}
