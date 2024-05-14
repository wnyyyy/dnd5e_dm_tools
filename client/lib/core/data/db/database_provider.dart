import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

class DatabaseProvider {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> setData({
    required String path,
    required Map<String, dynamic> data,
    required bool offline,
    required String cacheBoxName,
  }) async {
    if (!offline) {
      final reference = _db.doc(path);
      await reference.set(data);
    }
    final cacheBox = Hive.box<Map>(cacheBoxName);
    print('Setting data for $path');
    await cacheBox.put(path, data);
    final test = cacheBox.get(path);
    print('Data set for $path: $test');
    print('total items in cache: ${cacheBox.length}');
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
      if (cacheBoxName != null) {
        final cacheBox = Hive.box<Map>(cacheBoxName);
        await cacheBox.put(doc.id, doc.data());
      }
    }

    print('Fetched $path from Firestore');
    return data;
  }

  Future<void> loadCache(String cacheBoxName) async {
    print('Checking cache for $cacheBoxName...');
    try {
      var box = await Hive.openBox<Map>(cacheBoxName);
      print('Cache for $cacheBoxName loaded with ${box.length} items');
    } catch (e) {
      print('Error loading cache from .hive file: $e // $cacheBoxName');
    }
  }
}
