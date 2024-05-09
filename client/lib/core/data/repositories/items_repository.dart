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

  Future<dynamic> getMagicItem(String slug) async {
    final data = await databaseProvider.getDocument(
        path: '$magicItemsPath$slug', cacheBoxName: cacheMagicItems);
    return data;
  }

  Future<Map<String, Map<String, dynamic>>> getAll() async {
    final data = await databaseProvider.getCollection(
        path: path, cacheBoxName: cacheItemsName);
    return data;
  }

  Future<Map<String, Map<String, dynamic>>> getAllMagicItems() async {
    final data = await databaseProvider.getCollection(
        path: magicItemsPath, cacheBoxName: cacheMagicItems);
    return data;
  }
}
