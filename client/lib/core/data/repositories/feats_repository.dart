import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';

class FeatsRepository {
  final DatabaseProvider databaseProvider;
  final path = 'feats/';

  FeatsRepository(this.databaseProvider);

  Future<void> init() async {
    await databaseProvider.loadCache(cacheFeatsName);
  }

  Future<dynamic> get(String slug) async {
    final data = await databaseProvider.getDocument(
        path: '$path$slug', cacheBoxName: cacheFeatsName);
    return data;
  }

  Future<Map<String, Map<String, dynamic>>> getAll() async {
    final data = await databaseProvider.getCollection(
        path: path, cacheBoxName: cacheFeatsName);
    return data;
  }
}
