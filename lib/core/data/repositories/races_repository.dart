import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:logger/logger.dart';

class RacesRepository {
  RacesRepository(this.databaseProvider);
  final DatabaseProvider databaseProvider;

  Future<void> init() async {
    await databaseProvider.loadCache(cacheRacesName);
  }

  Future<Race> get(String slug) async {
    final data = await databaseProvider.getDocument(
      path: '$firebaseRacesPath/$slug',
      cacheBoxName: cacheRacesName,
    );
    if (data == null) {
      logRep('Race not found: $slug', level: Level.warning);
      throw Exception('Race not found');
    }
    final race = Race.fromJson(data, slug);
    return race;
  }

  Future<List<Race>> getAll() async {
    final data = await databaseProvider.getCollection(
      path: firebaseRacesPath,
      cacheBoxName: cacheRacesName,
    );
    final List<Race> races = [];
    for (final entry in data.entries) {
      final slug = entry.key;
      final raceData = entry.value;
      try {
        final race = Race.fromJson(raceData, slug);
        races.add(race);
      } catch (e) {
        logRep('Error parsing Race $slug: $e', level: Level.error);
      }
    }
    return races;
  }

  Future<void> sync(String slug, Race race) async {
    final entry = race.toJson();
    await databaseProvider.setData(
      path: slug,
      data: entry,
      offline: true,
      cacheBoxName: cacheRacesName,
    );
  }

  Future<void> save(String slug, Race race, bool offline) async {
    final entry = race.toJson();
    await databaseProvider.setData(
      path: '$firebaseRacesPath/$slug',
      data: entry,
      offline: offline,
      cacheBoxName: cacheRacesName,
    );
  }
}
