import 'package:dnd5e_dm_tools/core/data/db/realtime_database_provider.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/models/adventure.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/models/character.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/models/location.dart';
import 'package:firebase_database/firebase_database.dart';

class CampaignRepository {
  CampaignRepository(this.databaseProvider);
  final RealtimeDatabaseProvider databaseProvider;

  Stream<List<Location>> getLocationsStream() {
    return databaseProvider.onValueStream('locations').map((event) {
      final locationsMap = event.snapshot.value as Map<dynamic, dynamic>?;
      return locationsMap?.keys.map((key) {
            return Location.fromJson(
              Map<String, dynamic>.from(locationsMap[key] as Map),
              key.toString(),
            );
          }).toList() ??
          [];
    });
  }

  Future<void> updateLocation(
    String locationName,
    String entryId,
    String content,
  ) async {
    final DatabaseReference ref = FirebaseDatabase.instance
        .ref('locations/$locationName/entries/$entryId');
    if (content.isEmpty) {
      await ref.remove();
    } else {
      await ref.set(content);
    }
  }

  Future<void> addLocationEntry(String locationName, String content) async {
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('locations/$locationName/entries').push();
    await ref.set(content);
  }

  Stream<List<Character>> getCharactersStream() {
    return databaseProvider.onValueStream('characters').map(
      (event) {
        final charactersMap = event.snapshot.value as Map<dynamic, dynamic>?;
        return charactersMap?.keys.map((key) {
              return Character.fromJson(
                Map<String, dynamic>.from(charactersMap[key] as Map),
                key.toString(),
              );
            }).toList() ??
            [];
      },
    );
  }

  Future<void> updateCharacter(
    String characterName,
    String entryId,
    String content,
  ) async {
    final DatabaseReference ref = FirebaseDatabase.instance
        .ref('characters/$characterName/entries/$entryId');
    if (content.isEmpty) {
      await ref.remove();
    } else {
      await ref.set(content);
    }
  }

  Future<void> addCharacterEntry(String characterName, String content) async {
    final DatabaseReference ref = FirebaseDatabase.instance
        .ref('characters/$characterName/entries')
        .push();
    await ref.set(content);
  }

  Stream<Adventure> getAdventureStream() {
    return databaseProvider.onValueStream('adventure').map(
      (event) {
        final snapshot = event.snapshot.value ?? [];
        return Adventure.fromJson(
          snapshot,
        );
      },
    );
  }

  Future<void> updateAdventureEntry(String entryId, String content) async {
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('adventure/$entryId');
    if (content.isEmpty) {
      await ref.remove();
    } else {
      await ref.set(content);
    }
  }

  Future<void> addAdventureEntry(String content) async {
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('adventure').push();
    await ref.set(content);
  }
}
