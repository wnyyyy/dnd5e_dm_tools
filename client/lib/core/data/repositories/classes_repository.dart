import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';

class ClassesRepository {
  final DatabaseProvider databaseProvider;
  final path = 'classes/';

  ClassesRepository(this.databaseProvider);

  Future<void> init() async {
    await databaseProvider.loadCache(cacheSpellsName);
  }

  Future<dynamic> get(String slug) async {
    final data = await databaseProvider.getDocument(
        path: '$path$slug', cacheBoxName: cacheClassesName);
    return data;
  }

  Future<void> updateClass(String slug, Map<String, dynamic> classs) async {
    await databaseProvider.setData(
      path: '$path$slug',
      data: classs,
    );
  }

  Future<Map<String, Map<String, dynamic>>> getAll() async {
    final data = await databaseProvider.getCollection(path: path);
    return data;
  }
}
