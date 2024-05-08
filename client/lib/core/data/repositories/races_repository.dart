import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';

class RacesRepository {
  final DatabaseProvider databaseProvider;
  final path = 'races/';

  RacesRepository(this.databaseProvider);

  Future<dynamic> get(String slug) async {
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

  Future<dynamic> getAll() async {
    final docs = await databaseProvider.getCollection(path: path);
    return docs.fold<Map<String, Map<String, dynamic>>>(
      {},
      (previousValue, element) {
        previousValue[element.id] = {'id': element.id, ...element.data() ?? {}};
        return previousValue;
      },
    );
  }

  Future<void> create(String slug, Map<String, dynamic> race) async {
    await databaseProvider.setData(
      path: '$path${race['slug']}',
      data: race,
    );
  }

  Future<void> update(String slug, Map<String, dynamic> race) async {
    await databaseProvider.setData(
      path: '$path$race',
      data: race,
    );
  }
}
