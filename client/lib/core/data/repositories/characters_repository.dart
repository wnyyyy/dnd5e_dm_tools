import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';

class CharactersRepository {
  final DatabaseProvider databaseProvider;
  final path = 'feats/';

  CharactersRepository(this.databaseProvider);

  Future<dynamic> get(String slug) async {
    final docSnapshot =
        await databaseProvider.getDocument(path: 'characters/$slug');
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data == null) {
        return null;
      }
      return data;
    }
    return null;
  }

  Future<void> updateCharacter(
      String slug, Map<String, dynamic> character) async {
    await databaseProvider.setData(
      path: 'characters/$slug',
      data: character,
    );
  }

  Future<List<dynamic>> getAll() async {
    final querySnapshot =
        await databaseProvider.getCollection(path: 'characters/');
    List<dynamic> characters = [];
    for (var doc in querySnapshot) {
      var data = doc.data();
      if (data != null) {
        characters.add(data);
      }
    }
    return characters;
  }
}
