import 'package:dnd5e_dm_tools/core/data/db/realtime_database_provider.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/models/adventure.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/models/bullet_point.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/models/character.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/models/location.dart';
import 'package:firebase_database/firebase_database.dart';

class CampaignRepository {
  final RealtimeDatabaseProvider databaseProvider;

  CampaignRepository(this.databaseProvider);

  Stream<List<Location>> getLocationsStream() {
    return databaseProvider.onValueStream('locations').map((event) {
      final locationsMap = event.snapshot.value as Map<dynamic, dynamic>?;
      return locationsMap?.entries.map((e) {
            return Location.fromJson(
                Map<String, dynamic>.from(e.value as Map), e.key);
          }).toList() ??
          [];
    });
  }

  Future<List<Location>> getLocations() async {
    final data = await databaseProvider.readData('locations/');
    if (data.value == null) {
      return [];
    }
    final locations = <Location>[];
    if (data.value != null) {
      Map<String, dynamic> locationsMap =
          Map<String, dynamic>.from(data.value as Map);
      locationsMap.forEach((key, value) {
        locations.add(
          Location.fromJson(Map<String, dynamic>.from(value), key),
        );
      });
    }
    return locations;
  }

  Future<void> updateLocation(int id, String name, String content) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('locations/$id');
    await ref.update({'name': name, 'content': content});
  }

  Future<List<Character>> getCharacters() async {
    final data = await databaseProvider.readData('characters/');
    if (data.value == null) {
      return [];
    }
    final characters = <Character>[];
    if (data.value != null) {
      Map<String, dynamic> charactersMap =
          Map<String, dynamic>.from(data.value as Map);
      charactersMap.forEach((key, value) {
        characters.add(
          Character.fromJson(Map<String, dynamic>.from(value), key),
        );
      });
    }
    return characters;
  }

  Future<Adventure> getAdventure() async {
    final data = await databaseProvider.readData('adventure/');
    if (data.value == null) {
      return const Adventure(entries: []);
    }
    final entries = <BulletPoint>[];
    if (data.value != null) {
      Map<String, dynamic> entriesMap =
          Map<String, dynamic>.from(data.value as Map);
      entriesMap.forEach((key, value) {
        entries.add(BulletPoint.fromJson(Map<String, dynamic>.from(value)));
      });
    }
    return Adventure(entries: entries);
  }
}
