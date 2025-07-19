import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/models/item.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:logger/logger.dart';

class ItemsRepository {
  ItemsRepository(this.databaseProvider);
  final DatabaseProvider databaseProvider;

  Future<void> init() async {
    await databaseProvider.loadCache(cacheItemsName);
  }

  Future<Item> get(String slug) async {
    final data = await databaseProvider.getDocument(
      path: '$firebaseItemsPath/$slug',
      cacheBoxName: cacheItemsName,
    );
    if (data == null) {
      logRep('Item not found: $slug', level: Level.warning);
      throw Exception('Item not found');
    }
    final item = Item.fromJson(data, slug);
    return item;
  }

  Future<List<Item>> getAll() async {
    final data = await databaseProvider.getCollection(
      path: firebaseItemsPath,
      cacheBoxName: cacheItemsName,
    );
    final List<Item> items = [];
    for (final entry in data.entries) {
      final slug = entry.key;
      final itemData = entry.value;
      try {
        final item = Item.fromJson(itemData, slug);
        items.add(item);
      } catch (e) {
        logRep('Error parsing Item $slug: $e', level: Level.error);
      }
    }
    return items;
  }

  Future<void> sync(String slug, Item item) async {
    final entry = item.toJson();
    await databaseProvider.setData(
      path: slug,
      data: entry,
      offline: true,
      cacheBoxName: cacheItemsName,
    );
  }

  Future<void> save(String slug, Item item, bool offline) async {
    final entry = item.toJson();
    await databaseProvider.setData(
      path: '$firebaseItemsPath/$slug',
      data: entry,
      offline: offline,
      cacheBoxName: cacheItemsName,
    );
  }
}
