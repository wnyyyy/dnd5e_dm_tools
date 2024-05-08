import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class DatabaseProvider {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> setData({
    required String path,
    required Map<String, dynamic> data,
    String? cacheBoxName,
  }) async {
    final reference = _db.doc(path);
    await reference.set(data);
    if (cacheBoxName != null) {
      final cacheBox = Hive.box<Map<String, dynamic>>(cacheBoxName);
      await cacheBox.put(path, data);
    }
  }

  Future<Map<String, dynamic>?> getDocument({
    required String path,
    String? cacheBoxName,
  }) async {
    if (cacheBoxName != null) {
      final cacheBox = Hive.box<Map<String, dynamic>>(cacheBoxName);
      var cachedData = cacheBox.get(path);
      if (cachedData != null) {
        return cachedData;
      }
    }

    final reference = _db.doc(path);
    var snapshot = await reference.get();
    if (snapshot.exists) {
      if (cacheBoxName != null) {
        final cacheBox = Hive.box<Map<String, dynamic>>(cacheBoxName);
        await cacheBox.put(path, snapshot.data()!);
      }
      return snapshot.data();
    }
    return null;
  }

  Future<void> deleteData({
    required String path,
    String? cacheBoxName,
  }) async {
    final reference = _db.doc(path);
    await reference.delete();
    if (cacheBoxName != null) {
      final cacheBox = Hive.box<Map<String, dynamic>>(cacheBoxName);
      await cacheBox.delete(path);
    }
  }

  Future<void> updateData({
    required String path,
    required Map<String, dynamic> data,
    String? cacheBoxName,
  }) async {
    final reference = _db.doc(path);
    await reference.update(data);
    if (cacheBoxName != null) {
      final cacheBox = Hive.box<Map<String, dynamic>>(cacheBoxName);
      await cacheBox.put(path, data);
    }
  }

  Future<Map<String, Map<String, dynamic>>> getCollection({
    required String path,
    String? cacheBoxName,
  }) async {
    final Map<String, Map<String, dynamic>> data = {};

    if (cacheBoxName != null) {
      final cacheBox = Hive.box<Map<String, dynamic>>(cacheBoxName);
      if (cacheBox.isNotEmpty) {
        return cacheBox.toMap().cast<String, Map<String, dynamic>>();
      }
    }

    final reference = _db.collection(path);
    final snapshot = await reference.get();

    for (var doc in snapshot.docs) {
      data[doc.id] = doc.data();
    }
    if (cacheBoxName != null) {
      Hive.box<Map<String, dynamic>>(cacheBoxName).putAll(data);
    }

    return data;
  }

  Future<void> loadCache(String cacheBoxName) async {
    var box = await Hive.openBox<Map<String, dynamic>>(cacheBoxName);
    if (box.isEmpty) {
      String data = await rootBundle.loadString('assets/$cacheBoxName');
      Map<String, dynamic> defaultData = json.decode(data);
      for (var key in defaultData.keys) {
        await box.put(key, defaultData[key]);
      }
    }
  }

  Future<void> saveDataToJsonFile(String boxName, String fileName) async {
    Map<String, dynamic> data = await _fetchAllDataFromHive(boxName);
    String jsonString = json.encode(data);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(jsonString);

    print('Data saved to ${file.path}');
  }

  Future<Map<String, dynamic>> _fetchAllDataFromHive(String boxName) async {
    var box = await Hive.openBox<Map<String, dynamic>>(boxName);
    Map<String, dynamic> data = {};
    for (var key in box.keys) {
      data[key] = box.get(key);
    }
    await box.close();

    return data;
  }
}
