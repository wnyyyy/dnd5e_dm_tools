import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';

class CharacterRepository {
  final DatabaseProvider databaseProvider;

  CharacterRepository(this.databaseProvider);

  Future<List<Race>> getAllCharacters() async {
    final db = await databaseProvider.database;
    var races = await db.query('Races', orderBy: 'name');
    List<Race> raceList =
        races.isNotEmpty ? races.map((c) => Race.fromMap(c)).toList() : [];
    return raceList;
  }
}
