import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseProvider {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Box<Map<String, dynamic>> _cacheBox = Hive.box('firestore_cache');

  Future<void> setData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final reference = _db.doc(path);
    await reference.set(data);
    await _cacheBox.put(path, data);
  }

  Future<Map<String, dynamic>?> getDocument({
    required String path,
    bool cache = true,
  }) async {
    if (cache) {
      var cachedData = _cacheBox.get(path);
      if (cachedData != null) {
        return cachedData;
      }
    }

    final reference = _db.doc(path);
    var snapshot = await reference.get();
    if (snapshot.exists) {
      if (cache) {
        await _cacheBox.put(path, snapshot.data()!);
      }
      return snapshot.data();
    }
    return null;
  }

  Future<void> deleteData({
    required String path,
  }) async {
    final reference = _db.doc(path);
    await reference.delete();
    await _cacheBox.delete(path);
  }

  Future<void> updateData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final reference = _db.doc(path);
    await reference.update(data);
    await _cacheBox.put(path, data);
  }

  Future<Map<String, Map<String, dynamic>>> getCollection({
    required String path,
    bool cache = true,
  }) async {
    final Map<String, Map<String, dynamic>> data = {};

    if (cache && _cacheBox.isNotEmpty) {
      for (var key in _cacheBox.keys) {
        var cachedData = _cacheBox.get(key);
        if (cachedData != null) {
          data[key] = cachedData.cast<String, dynamic>();
        }
      }
      return data;
    }

    final reference = _db.collection(path);
    final snapshot = await reference.get();

    for (var doc in snapshot.docs) {
      data[doc.id] = doc.data();
      if (cache) {
        _cacheBox.put(doc.id, doc.data());
      }
    }

    return data;
  }

  Future<Map<String, dynamic>> fetchAllDataFromHive(String boxName) async {
    var box = await Hive.openBox<Map<String, dynamic>>(boxName);
    Map<String, dynamic> data = {};
    for (var key in box.keys) {
      data[key] = box.get(key);
    }
    await box.close();
    return data;
  }

  Future<void> saveDataToJsonFile(String boxName, String fileName) async {
    Map<String, dynamic> data = await fetchAllDataFromHive(boxName);
    String jsonString = json.encode(data);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(jsonString);

    print('Data saved to ${file.path}');
  }
}
