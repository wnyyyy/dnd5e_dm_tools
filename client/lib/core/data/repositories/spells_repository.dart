import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';

class SpellsRepository {
  final DatabaseProvider databaseProvider;
  final spellsCache = <String, Map<String, dynamic>>{};
  final path = 'spells/';

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
}
