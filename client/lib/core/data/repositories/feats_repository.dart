import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';

class FeatsRepository {

  FeatsRepository(this.databaseProvider);
  final DatabaseProvider databaseProvider;
  final path = 'feats/';

  Future<void> init() async {
    await databaseProvider.loadCache(cacheFeatsName);
  }

  Future<dynamic> get(String slug) async {
    final data = await databaseProvider.getDocument(
        path: '$path$slug', cacheBoxName: cacheFeatsName,);
    return data;
  }

  Future<Map<String, Map<String, dynamic>>> getAll() async {
    final data = await databaseProvider.getCollection(
        path: path, cacheBoxName: cacheFeatsName,);
    return data;
  }

  Future<void> sync(
    String slug,
    Map<String, dynamic> entry,
  ) async {
    await databaseProvider.setData(
      path: slug,
      data: entry,
      offline: true,
      cacheBoxName: cacheFeatsName,
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
      cacheBoxName: cacheFeatsName,
    );
  }
}
