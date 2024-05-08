import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';

class SpellsRepository {
  final DatabaseProvider databaseProvider;
  final path = 'spells/';
  final spellListsPath = 'spelllist/';
  final shouldCache = true;

  SpellsRepository(this.databaseProvider);

  Future<dynamic> get(String slug) async {
    final data = await databaseProvider.getDocument(
        path: '$path$slug', cache: shouldCache);
    return data;
  }

  Future<Map<String, Map<String, dynamic>>> getAll() async {
    final data = await databaseProvider.getCollection(path: path);
    return data;
  }

  Future<Map<String, Map<String, dynamic>>> getSpellLists() async {
    final data = await databaseProvider.getCollection(path: spellListsPath);
    return data;
  }
}
