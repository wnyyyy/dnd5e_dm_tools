import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/race_repository.dart';

class CharacterRepository {
  final DatabaseProvider databaseProvider;
  final path = 'feats/';

  CharacterRepository(this.databaseProvider);

  Future<Character?> get(String name) async {
    final raceRepository = RaceRepository(databaseProvider);
    final docSnapshot =
        await databaseProvider.getDocument(path: 'characters/$name');
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data == null) {
        return null;
      }
      final race_slug = data['race_slug'];
      final race = await raceRepository.getJson(race_slug);
      return Character.fromMap(data, race);
    }
    return null;
  }

  Future<void> updateCharacter(Character character) async {
    await databaseProvider.setData(
      path: 'characters/${character.name}',
      data: character.toMap(),
    );
  }

  Future<List<Character>> getAll() async {
    final raceRepository = RaceRepository(databaseProvider);
    var charactersJson = [];
    databaseProvider.collectionStream(
      path: 'characters',
      builder: (data, documentId) => charactersJson.add(data),
    );
    var characters = <Character>[];
    for (var characterJson in charactersJson) {
      final race_slug = characterJson['raceslug'];
      final race = await raceRepository.getJson(race_slug);
      characters.add(Character.fromMap(characterJson, race));
    }

    return characters;
  }
}
