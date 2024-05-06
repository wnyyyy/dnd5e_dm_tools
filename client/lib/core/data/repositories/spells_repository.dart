import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';

class SpellsRepository {
  final DatabaseProvider databaseProvider;
  var spellsCache = <String, Map<String, dynamic>>{};
  final path = 'spells/';
  final spellListsPath = 'spelllist/';
  final extraSuffix = ['a5e'];

  SpellsRepository(this.databaseProvider);

  Future<Map<String, dynamic>?> get(String slug) async {
    if (spellsCache.containsKey(slug)) {
      return spellsCache[slug];
    }
    final docSnapshot = await databaseProvider.getDocument(path: '$path$slug');
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data == null) {
        return null;
      }
      spellsCache[slug] = data;
      return data;
    }
    return null;
  }

  Future<Map<String, Map<String, dynamic>>> getAll() async {
    if (spellsCache.isNotEmpty) {
      return spellsCache;
    }
    final docs = await databaseProvider.getCollection(path: path);
    return docs.fold<Map<String, Map<String, dynamic>>>(
      {},
      (previousValue, element) {
        previousValue[element.id] = {'id': element.id, ...element.data() ?? {}};
        spellsCache[element.id] = {'id': element.id, ...element.data() ?? {}};
        return previousValue;
      },
    );
  }

  Future<Map<String, Map<String, dynamic>>> getByClass(String classSlug) async {
    if (spellsCache.isNotEmpty) {
      return spellsCache;
    }
    final classSpells =
        await databaseProvider.getDocument(path: '$spellListsPath$classSlug');
    if (!classSpells.exists) {
      return {};
    }
    final allSpells = await getAll();
    Map<String, Map<String, dynamic>> spellList = {};
    for (var spell in classSpells.data()!['spells']) {
      spellList[spell] = allSpells[spell] ?? {};
      for (var suffix in extraSuffix) {
        final extraSpell = allSpells['$spell-$suffix'];
        if (extraSpell != null) {
          spellList['$spell-$suffix'] = extraSpell;
        }
      }
    }
    spellsCache = spellList;
    return spellList;
  }

  void clearCache() {
    spellsCache.clear();
  }
}
