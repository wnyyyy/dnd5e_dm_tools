import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';

class SpellsRepository {

  SpellsRepository(this.databaseProvider);
  final DatabaseProvider databaseProvider;
  final path = 'spells/';
  final spellListsPath = 'spelllist/';

  Future<void> init() async {
    await databaseProvider.loadCache(cacheSpellsName);
    await databaseProvider.loadCache(cacheSpellListsName);
  }

  Future<dynamic> get(String slug) async {
    final data = await databaseProvider.getDocument(
        path: '$path$slug', cacheBoxName: cacheSpellsName,);
    return data;
  }

  Future<Map<String, Map<String, dynamic>>> getAll() async {
    final data = await databaseProvider.getCollection(
        path: path, cacheBoxName: cacheSpellsName,);
    return data;
  }

  Future<Map<String, Map<String, dynamic>>> getSpellLists() async {
    final data = await databaseProvider.getCollection(
        path: spellListsPath, cacheBoxName: cacheSpellListsName,);
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
      cacheBoxName: cacheSpellsName,
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
      cacheBoxName: cacheSpellsName,
    );
  }
}
