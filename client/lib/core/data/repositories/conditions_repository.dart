import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';

class ConditionsRepository {
  final DatabaseProvider databaseProvider;
  final path = 'conditions/';

  ConditionsRepository(this.databaseProvider);

  Future<void> init() async {
    await databaseProvider.loadCache(cacheConditionsName);
  }

  Future<dynamic> get(String slug) async {
    final data = await databaseProvider.getDocument(
        path: '$path$slug', cacheBoxName: cacheConditionsName);
    return data;
  }

  Future<Map<String, Map<String, dynamic>>> getAll() async {
    final data = await databaseProvider.getCollection(
        path: path, cacheBoxName: cacheConditionsName);
    return data;
  }
}
