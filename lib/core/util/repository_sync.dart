import 'dart:convert';
import 'dart:io';
import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/models/asi.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/character_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/race_repository.dart';
import 'package:dnd5e_dm_tools/core/util/constants.dart';
import 'package:http/http.dart';

class RepositorySync {
  static Future<void> sync(DatabaseProvider databaseProvider) async {
    await RepositorySync.syncRaces(databaseProvider);
  }

  static Future<void> syncRaces(DatabaseProvider databaseProvider) async {
    final Response response = await get(Uri.parse('${BASE_API_URL}races/'));
    if (response.statusCode == 200) {
      var raceRepository = RaceRepository(databaseProvider);
      var jsonResponse = jsonDecode(response.body);
      var racesJson = jsonResponse['results'];
      for (var entry in racesJson) {
        var asiJson = entry['asi'];
        var asiList = <ASI>[];
        for (var asiEntry in asiJson) {
          var asi = ASI(
            raceSlug: entry['slug'],
            attribute: asiEntry['attributes'][0],
            value: asiEntry['value'],
          );
          asiList.add(asi);
        }
        var race = Race(
            slug: entry['slug'],
            name: entry['name'],
            description: entry['desc'],
            asi: asiList,
            speed: entry['speed']['walk'],
            languages: entry['languages'],
            vision: entry['vision'],
            traits: entry['traits']);
        await raceRepository.insertRace(race);
      }
    }
  }

  static Future<void> addCustomEntries(
      DatabaseProvider databaseProvider) async {
    var customDb = await File('CustomDb.json').readAsString();
    var map = jsonDecode(customDb);
    RaceRepository raceRepository = RaceRepository(databaseProvider);
    for (Map<String, dynamic> raceJson in map['races']) {
      String fallbackRaceSlug = raceJson['fallback'];
      var fallbackRace = await raceRepository.getRace(fallbackRaceSlug);
      if (fallbackRace == null) {
        continue;
      }
      var fallbackRaceMap = fallbackRace.toMap();
      for (var entry in raceJson.keys) {
        fallbackRaceMap[entry] = raceJson[entry];
      }
      Race newRace = Race.fromMap(fallbackRaceMap);
      await raceRepository.insertRace(newRace);
    }

    CharacterRepository characterRepository =
        CharacterRepository(databaseProvider);
    for (Map<String, dynamic> characterJson in map['characters']) {
      Race? race = await raceRepository.getRace(characterJson['race_slug']);
      if (race == null) {
        continue;
      }
      await characterRepository
          .insertCharacter(Character.fromMap(characterJson, race.toMap()));
    }
  }
}
