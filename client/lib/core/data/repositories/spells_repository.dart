import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';

class SpellsRepository {
  final DatabaseProvider databaseProvider;
  final path = 'spells/';
  final spellListsPath = 'spelllist/';

  SpellsRepository(this.databaseProvider);

  Future<void> init() async {
    await databaseProvider.loadCache(cacheSpellsName);
    await databaseProvider.loadCache(cacheSpellListsName);
  }

  Future<dynamic> get(String slug) async {
    final data = await databaseProvider.getDocument(
        path: '$path$slug', cacheBoxName: cacheSpellsName);
    return data;
  }

  Future<Map<String, Map<String, dynamic>>> getAll() async {
    final data = await databaseProvider.getCollection(
        path: path, cacheBoxName: cacheSpellsName);
    return data;
  }

  Future<Map<String, Map<String, dynamic>>> getSpellLists() async {
    final data = await databaseProvider.getCollection(
        path: spellListsPath, cacheBoxName: cacheSpellListsName);
    return data;
  }
}
