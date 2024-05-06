import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';

class CharacterRepository {
  final DatabaseProvider databaseProvider;
  final path = 'feats/';

  CharacterRepository(this.databaseProvider);

  Future<dynamic> get(String name) async {
    final nameL = name.toLowerCase();
    final docSnapshot =
        await databaseProvider.getDocument(path: 'characters/$nameL');
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
      String name, Map<String, dynamic> character) async {
    await databaseProvider.setData(
      path: 'characters/$name',
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
