import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';

class RaceRepository {
  final DatabaseProvider databaseProvider;
  final path = 'races/';

  RaceRepository(this.databaseProvider);

  Future<dynamic> getJson(String name) async {
    final docSnapshot = await databaseProvider.getDocument(path: '$path$name');
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data == null) {
        return null;
      }
      return data;
    }
    return null;
  }

  Future<Race?> get(String name) async {
    final docSnapshot = await databaseProvider.getDocument(path: '$path$name');
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data == null) {
        return null;
      }
      return Race.fromMap(data);
    }
    return null;
  }

  Future<void> update(Race race) async {
    var json = await getJson(race.slug);
    if (json == null) {
      return;
    }
    final raceMap = race.toMap();
    for (var key in raceMap.keys) {
      if (json[key] != raceMap[key]) {
        json[key] = raceMap[key];
      }
    }
    await databaseProvider.setData(
      path: '$path${race.slug}',
      data: json,
    );
  }
}
