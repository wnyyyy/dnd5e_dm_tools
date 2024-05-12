import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';

class ItemsRepository {
  final DatabaseProvider databaseProvider;
  final path = 'equipment/';
  final magicItemsPath = 'magicitems/';

  ItemsRepository(this.databaseProvider);

  Future<void> init() async {
    await databaseProvider.loadCache(cacheMagicItems);
    await databaseProvider.loadCache(cacheItemsName);
  }

  Future<dynamic> get(String slug) async {
    final data = await databaseProvider.getDocument(
        path: '$path$slug', cacheBoxName: cacheItemsName);
    return data;
  }

  Future<Map<String, Map<String, dynamic>>> getAll() async {
    final data = await databaseProvider.getCollection(
        path: path, cacheBoxName: cacheItemsName);
    return data;
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
      cacheBoxName: cacheItemsName,
    );
  }
}
