import 'dart:convert';
import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/race_repository.dart';
import 'package:dnd5e_dm_tools/core/util/constants.dart';
import 'package:http/http.dart';

class RepositorySync {
  static Future<void> sync() async {
    await RepositorySync.syncRaces();
  }

  static Future<void> syncRaces() async {
    final Response response = await get(Uri.parse('${BASE_API_URL}races/'));
    if (response.statusCode == 200) {
      var raceRepository = RaceRepository(DatabaseProvider());
      var jsonResponse = jsonDecode(response.body);
      var races = jsonResponse['results'];
      for (var race in races) {
        await raceRepository.insertRace(Race.fromOpenApi(race));
      }
    }
  }
}
