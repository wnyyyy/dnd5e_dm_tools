import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';

class SpellsRepository {
  final DatabaseProvider databaseProvider;
  final path = 'spells/';

  SpellsRepository(this.databaseProvider);

  Future<Map<String, dynamic>?> get(String slug) async {
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
    final docs = await databaseProvider.getCollection(path: path);
    return docs.fold<Map<String, Map<String, dynamic>>>(
      {},
      (previousValue, element) {
        previousValue[element.id] = {'id': element.id, ...element.data() ?? {}};
        return previousValue;
      },
    );
  }
}
