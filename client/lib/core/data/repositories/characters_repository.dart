import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';

class CharactersRepository {
  final DatabaseProvider databaseProvider;
  final path = 'characters/';

  CharactersRepository(this.databaseProvider);

  Future<dynamic> get(String slug) async {
    final data = await databaseProvider.getDocument(path: '$path$slug');
    return data;
  }

  Future<void> updateCharacter(
      String slug, Map<String, dynamic> character) async {
    await databaseProvider.setData(
      path: '$path$slug',
      data: character,
    );
  }

  Future<Map<String, Map<String, dynamic>>> getAll() async {
    final data = await databaseProvider.getCollection(path: path);
    return data;
  }
}
