import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

class DatabaseProvider {
  final FirebaseFirestore _firebaseDB = FirebaseFirestore.instance;

  Future<void> setData({
    required String path,
    required Map<String, dynamic> data,
    required bool offline,
    String? cacheBoxName,
  }) async {
    if (!offline) {
      final reference = _firebaseDB.doc(path);
      await reference.set(data);
    } else {
      logDB('Offline mode enabled. Skipping Firestore update for $path');
    }
    if (cacheBoxName == null) {
      logDB('No cache box name provided. Skipping cache update for $path');
      return;
    }
    final cacheBox = Hive.box<Map>(cacheBoxName);
    logDB('Setting data for $path');
    await cacheBox.put(path, data);
    logDB('Data set for $path');
  }

  Future<Map<String, dynamic>?> getDocument({
    required String path,
    String? cacheBoxName,
  }) async {
    logDB('Getting document: $path');
    if (cacheBoxName != null) {
      final cacheBox = Hive.box<Map>(cacheBoxName);
      final cachedData = cacheBox.get(path);
      if (cachedData != null) {
        final casted = Map<String, dynamic>.from(cachedData);
        logDB('Found cache data for $path');
        return casted;
      }
    }

    logDB('No cache data found for $path // fetching from Firestore...');
    final reference = _firebaseDB.doc(path);
    final snapshot = await reference.get();
    if (snapshot.exists) {
      if (cacheBoxName != null) {
        final cacheBox = Hive.box<Map>(cacheBoxName);
        await cacheBox.put(path, snapshot.data()!);
      }
      logDB('Fetched $path from Firestore');
      return snapshot.data();
    }
    return null;
  }

  Future<Map<String, Map<String, dynamic>>> getCollection({
    required String path,
    String? cacheBoxName,
  }) async {
    final Map<String, Map<String, dynamic>> data = {};

    logDB('Getting collection: $path');
    if (cacheBoxName != null) {
      final cacheBox = Hive.box<Map>(cacheBoxName);
      if (cacheBox.isNotEmpty) {
        for (final key in cacheBox.keys) {
          try {
            final map = cacheBox.get(key);
            if (map != null) {
              final Map<String, dynamic> castedMap = {};
              map.forEach((k, v) {
                if (k is String) {
                  castedMap[k] = v;
                }
              });
              data[key.toString()] = castedMap;
            }
          } catch (e) {
            logDB('Error getting cache data: $e', level: Level.warning);
          }
        }
        logDB('Found cache data for $path // returning ${data.length} items');
        return data;
      }
    }
    logDB(
      cacheBoxName != null
          ? 'No cache data found for $path // fetching from Firestore...'
          : 'Fetching from Firestore...',
    );

    final reference = _firebaseDB.collection(path);
    final snapshot = await reference.get();

    for (final doc in snapshot.docs) {
      data[doc.id] = doc.data();
      if (cacheBoxName != null) {
        final cacheBox = Hive.box<Map>(cacheBoxName);
        await cacheBox.put(doc.id, doc.data());
      }
    }

    logDB('Fetched $path from Firestore');
    return data;
  }

  Future<void> loadCache(String cacheBoxName) async {
    logDB('Checking cache for $cacheBoxName...');
    try {
      final isOpen = Hive.isBoxOpen(cacheBoxName);
      final Box box;
      if (!isOpen) {
        box = await Hive.openBox<Map>(cacheBoxName);
      } else {
        box = Hive.box<Map>(cacheBoxName);
      }
      logDB('Cache for $cacheBoxName loaded with ${box.length} items');
    } catch (e) {
      logDB(
        'Error loading cache from .hive file: $e // $cacheBoxName',
        level: Level.error,
      );
    }
  }

  Future<void> clearCacheBox(String cacheBoxName) async {
    try {
      if (Hive.isBoxOpen(cacheBoxName)) {
        await Hive.box<Map>(cacheBoxName).clear();
      } else {
        final box = await Hive.openBox(cacheBoxName);
        await box.clear();
      }
      logDB('Cache cleared for $cacheBoxName');
    } catch (e) {
      logDB('Error clearing cache for $cacheBoxName: $e', level: Level.error);
    }
  }
}
