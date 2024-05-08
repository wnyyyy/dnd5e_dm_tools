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
      final cacheBox = Hive.box<Map>(cacheBoxName);
      await cacheBox.put(path, data);
    }
  }

  Future<Map<String, dynamic>?> getDocument({
    required String path,
    String? cacheBoxName,
  }) async {
    print('Getting document: $path');
    if (cacheBoxName != null) {
      final cacheBox = Hive.box<Map>(cacheBoxName);
      var cachedData = cacheBox.get(path);
      if (cachedData != null) {
        final casted = Map<String, dynamic>.from(cachedData);
        print('Found cache data for $path');
        return casted;
      }
    }

    print('No cache data found for $path // fetching from Firestore...');
    final reference = _db.doc(path);
    var snapshot = await reference.get();
    if (snapshot.exists) {
      if (cacheBoxName != null) {
        final cacheBox = Hive.box<Map>(cacheBoxName);
        await cacheBox.put(path, snapshot.data()!);
      }
      print('Fetched $path from Firestore');
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
      final cacheBox = Hive.box<Map>(cacheBoxName);
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
      final cacheBox = Hive.box<Map>(cacheBoxName);
      await cacheBox.put(path, data);
    }
  }

  Future<Map<String, Map<String, dynamic>>> getCollection({
    required String path,
    String? cacheBoxName,
  }) async {
    final Map<String, Map<String, dynamic>> data = {};

    print('Getting collection: $path');
    if (cacheBoxName != null) {
      final cacheBox = Hive.box<Map>(cacheBoxName);
      if (cacheBox.isNotEmpty) {
        for (var key in cacheBox.keys) {
          try {
            var map = cacheBox.get(key);
            if (map != null) {
              Map<String, dynamic> castedMap = {};
              map.forEach((k, v) {
                if (k is String) {
                  castedMap[k] = v;
                }
              });
              data[key] = castedMap;
            }
          } catch (e) {
            print('Error getting cache data: $e');
          }
        }
        print('Found cache data for $path // returning ${data.length} items');
        return data;
      }
    }
    print('No cache data found for $path // fetching from Firestore...');

    final reference = _db.collection(path);
    final snapshot = await reference.get();

    for (var doc in snapshot.docs) {
      data[doc.id] = doc.data();
    }

    print('Fetched $path from Firestore');
    return data;
  }

  Future<void> loadCache(String cacheBoxName) async {
    print('Checking cache for $cacheBoxName...');
    var box = await Hive.openBox<Map>(cacheBoxName);
    if (box.isEmpty) {
      print('Building cache for: $cacheBoxName...');
      try {
        String data = await rootBundle.loadString('assets/$cacheBoxName');
        Map<String, dynamic> defaultData = json.decode(data);
        for (var key in defaultData.keys) {
          await box.put(key, defaultData[key]);
        }
        print('Cache built for: $cacheBoxName');
      } catch (e) {
        print('Error loading cache asset: $e // $cacheBoxName');
      }
    }
    print('Cache for $cacheBoxName loaded with ${box.length} items');
  }

  Future<void> persistCache(String boxName) async {
    Map<String, dynamic> data = await _fetchAllDataFromHive(boxName);
    String jsonString = json.encode(data);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$boxName');
    await file.writeAsString(jsonString);

    print('Data saved to ${file.path} // $boxName');
  }

  Future<Map<String, dynamic>> _fetchAllDataFromHive(String boxName) async {
    var box = await Hive.openBox<Map>(boxName);
    Map<String, dynamic> data = {};
    for (var key in box.keys) {
      data[key] = box.get(key);
    }

    return data;
  }
}
