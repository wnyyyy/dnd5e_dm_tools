import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/race_repository.dart';

class CharacterRepository {
  final DatabaseProvider databaseProvider;

  CharacterRepository(this.databaseProvider);

  Future<Character> insertCharacter(Character character) async {
    final db = await databaseProvider.database;
    await db.insert('Characters', character.toMap());

    return character;
  }

  Future<Character?> getCharacter(String name) async {
    final db = await databaseProvider.database;
    var characterQuery =
        await db.query('Characters', where: 'name = ?', whereArgs: [name]);
    if (characterQuery.isEmpty) return null;
    Map<String, dynamic> characterMap = characterQuery[0];
    String raceSlug = characterMap['race_slug'];
    RaceRepository raceRepository = RaceRepository(databaseProvider);
    Map<String, dynamic> raceMap =
        (await raceRepository.getRace(raceSlug))?.toMap() ?? {};

    return Character.fromMap(characterMap, raceMap);
  }

  Future<void> updateAll(List<Character> characters) async {
    final db = await databaseProvider.database;
    await db.transaction((txn) async {
      await txn.delete('Characters');

      for (Character character in characters) {
        await txn.insert('Characters', character.toMap());
      }
    });
  }
}
