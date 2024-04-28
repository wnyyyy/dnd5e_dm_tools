import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';

class RaceRepository {
  final DatabaseProvider databaseProvider;
  final path = 'races/';

  RaceRepository(this.databaseProvider);

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

  Future<void> create(String slug, Map<String, dynamic> race) async {
    await databaseProvider.setData(
      path: '$path${race['slug']}',
      data: race,
    );
  }

  Future<void> update(String slug, Map<String, dynamic> race) async {
    await databaseProvider.setData(
      path: '$path${race}',
      data: race,
    );
  }
}
