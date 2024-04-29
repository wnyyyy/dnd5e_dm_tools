import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';

class FeatRepository {
  final DatabaseProvider databaseProvider;
  final path = 'feats/';

  FeatRepository(this.databaseProvider);

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

  Future<Map<String, dynamic>> getAll() async {
    final docs = await databaseProvider.getCollection(path: path);
    return docs.fold<Map<String, dynamic>>(
      {},
      (previousValue, element) {
        previousValue[element.id] = element.data();
        return previousValue;
      },
    );
  }

  Future<void> create(String slug, Map<String, dynamic> feat) async {
    await databaseProvider.setData(
      path: '$path${feat['slug']}',
      data: feat,
    );
  }

  Future<void> update(String slug, Map<String, dynamic> feat) async {
    await databaseProvider.setData(
      path: '$path${feat}',
      data: feat,
    );
  }
}
