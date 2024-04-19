import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';

class RaceRepository {
  final DatabaseProvider databaseProvider;

  RaceRepository(this.databaseProvider);

  Future<List<Race>> getAllRaces() async {
    final db = await databaseProvider.database;
    var races = await db.query('Races', orderBy: 'name');
    List<Race> raceList =
        races.isNotEmpty ? races.map((c) => Race.fromMap(c)).toList() : [];
    return raceList;
  }

  Future<Race?> getRace(String slug) async {
    final db = await databaseProvider.database;
    var race = await db.query('Races', where: 'slug = ?', whereArgs: [slug]);
    if (race.isEmpty) return null;
    return Race.fromMap(race[0]);
  }

  Future<Race> insertRace(Race race) async {
    final db = await databaseProvider.database;
    await db.insert('Races', race.toMap());
    return race;
  }

  Future<Race> updateRace(Race race) async {
    final db = await databaseProvider.database;
    await db.update(
      'Races',
      race.toMap(),
      where: 'name = ?',
      whereArgs: [race.name],
    );
    return race;
  }

  Future<void> deleteRace(String name) async {
    final db = await databaseProvider.database;
    await db.delete(
      'Races',
      where: 'name = ?',
      whereArgs: [name],
    );
  }
}
