import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:logger/logger.dart';

class ClassesRepository {
  ClassesRepository(this.databaseProvider);
  final DatabaseProvider databaseProvider;

  Future<void> init() async {
    await databaseProvider.loadCache(cacheClassesName);
  }

  Future<Class> get(String slug, {bool online = false}) async {
    final data = await databaseProvider.getDocument(
      path: '$firebaseClassesPath/$slug',
      cacheBoxName: online ? null : cacheClassesName,
    );
    if (data == null) {
      logRep('Class not found: $slug', level: Level.warning);
      throw Exception('Class not found');
    }
    final classs = Class.fromJson(data, slug);
    return classs;
  }

  Future<Map<String, dynamic>> getData(
    String slug, {
    bool online = false,
  }) async {
    final data = await databaseProvider.getDocument(
      path: '$firebaseClassesPath/$slug',
      cacheBoxName: online ? null : cacheClassesName,
    );
    if (data == null) {
      logRep('Class not found: $slug', level: Level.warning);
      throw Exception('Class not found');
    }
    return data;
  }

  Future<List<Class>> getAll({bool online = false}) async {
    final data = await databaseProvider.getCollection(
      path: firebaseClassesPath,
      cacheBoxName: online ? null : cacheClassesName,
    );
    final List<Class> classes = [];
    for (final entry in data.entries) {
      final slug = entry.key;
      final classData = entry.value;
      try {
        final classs = Class.fromJson(classData, slug);
        classes.add(classs);
      } catch (e) {
        logRep('Error parsing Class $slug: $e', level: Level.error);
      }
    }
    return classes;
  }

  Future<void> sync(String slug) async {
    final entry = await getData(slug, online: true);
    await databaseProvider.setData(
      path: '$firebaseClassesPath/$slug',
      data: entry,
      offline: true,
      cacheBoxName: cacheClassesName,
    );
  }

  Future<void> save(String slug, Class classs, bool offline) async {
    final entry = classs.toJson();
    await databaseProvider.setData(
      path: '$firebaseClassesPath/$slug',
      data: entry,
      offline: offline,
      cacheBoxName: cacheClassesName,
    );
  }

  Future<void> clearCache() async {
    await databaseProvider.clearCacheBox(cacheClassesName);
  }
}
