import 'dart:convert';
import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/character_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/feats_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/race_repository.dart';
import 'package:dnd5e_dm_tools/core/util/constants.dart';
import 'package:http/http.dart';

class ServerSync {
  static Future<void> checkUpdate(
      DatabaseProvider databaseProvider, bool syncCharOnly) async {
    final Response response = await get(Uri.parse('$SERVER_URL/db'));
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      DateTime serverTimestamp = DateTime.parse(json['timestamp']);
      if (databaseProvider.timestamp == null ||
          serverTimestamp.isAfter(databaseProvider.timestamp!)) {
        if (!syncCharOnly) {
          await _syncRaces(databaseProvider, json['data']);
          await _syncFeats(databaseProvider, json['data']);
        }
        await _syncCharacters(databaseProvider, json['data']);
        databaseProvider.timestamp = serverTimestamp;
      }
    }
  }

  static Future<void> _syncCharacters(
      DatabaseProvider databaseProvider, data) async {
    var charactersJson = data['characters'];
    var characterRepository = CharacterRepository(databaseProvider);
    var raceRepository = RaceRepository(databaseProvider);
    var characters = <Character>[];
    for (var characterJson in charactersJson) {
      var race = await raceRepository.getRace(characterJson['race_slug']);
      if (race == null) {
        continue;
      }
      var character = Character.fromMap(
        characterJson,
        race.toMap(),
      );
      characters.add(character);
    }
    await characterRepository.updateAll(characters);
  }

  static Future<void> _syncRaces(
      DatabaseProvider databaseProvider, data) async {
    var racesJson = data['races'];
    var raceRepository = RaceRepository(databaseProvider);
    var races = <Race>[];
    for (var raceJson in racesJson) {
      var race = Race.fromMap(raceJson);
      races.add(race);
    }
    await raceRepository.updateAll(races);
  }

  static Future<void> _syncFeats(
      DatabaseProvider databaseProvider, data) async {
    var featsJson = data['feats'];
    var featRepository = FeatRepository(databaseProvider);
    var feats = <Feat>[];
    for (var featJson in featsJson) {
      var feat = Feat.fromMap(featJson);
      feats.add(feat);
    }
    await featRepository.updateAll(feats);
  }
}
