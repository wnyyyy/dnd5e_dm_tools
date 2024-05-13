import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';

class ClassesRepository {
  final DatabaseProvider databaseProvider;
  final path = 'classes/';

  ClassesRepository(this.databaseProvider);

  Future<void> init() async {
    await databaseProvider.loadCache(cacheClassesName);
  }

  Future<dynamic> get(String slug) async {
    final data = await databaseProvider.getDocument(
        path: '$path$slug', cacheBoxName: cacheClassesName);
    return data;
  }

  Future<Map<String, Map<String, dynamic>>> getAll() async {
    final data = await databaseProvider.getCollection(
        path: path, cacheBoxName: cacheClassesName);
    return data;
  }

  Future<void> sync(
    String slug,
    Map<String, dynamic> entry,
  ) async {
    await databaseProvider.setData(
      path: '$path$slug',
      data: entry,
      offline: false,
      cacheBoxName: cacheClassesName,
    );
  }

  Future<void> save(
    String slug,
    Map<String, dynamic> entry,
    bool offline,
  ) async {
    await databaseProvider.setData(
      path: '$path$slug',
      data: entry,
      offline: offline,
      cacheBoxName: cacheClassesName,
    );
  }
}
