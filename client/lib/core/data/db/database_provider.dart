import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseProvider {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<T>> collectionStream<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentId) builder,
  }) {
    var reference = _db.collection(path);
    return reference.snapshots().map((snapshot) => snapshot.docs
        .map((snapshot) => builder(snapshot.data(), snapshot.id))
        .toList());
  }

  Future<void> setData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final reference = _db.doc(path);
    await reference.set(data);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String path,
  }) async {
    final reference = _db.doc(path);
    return reference.get();
  }

  Future<void> deleteData({
    required String path,
  }) async {
    final reference = _db.doc(path);
    await reference.delete();
  }

  Future<void> updateData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final reference = _db.doc(path);
    await reference.update(data);
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getCollection({
    required String path,
  }) async {
    final reference = _db.collection(path);
    final snapshot = await reference.get();
    return snapshot.docs;
  }
}
