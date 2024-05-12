import 'package:dnd5e_dm_tools/core/data/db/realtime_database_provider.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/models/adventure.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/models/bullet_point.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/models/character.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/models/location.dart';
import 'package:firebase_database/firebase_database.dart';

class CampaignRepository {
  final RealtimeDatabaseProvider databaseProvider;

  CampaignRepository(this.databaseProvider);

  Future<void> createCampaign(
      String campaignId, Map<String, dynamic> campaignData) async {
    await databaseProvider.writeData('campaigns/$campaignId', campaignData);
  }

  Future<List<Location>> getLocations() async {
    final data = await databaseProvider.readData('locations/');
    if (data.value == null) {
      return [];
    }
    final locations = <Location>[];
    if (data.value != null) {
      (data.value as Map).forEach((key, value) {
        locations.add(Location.fromJson(value));
      });
    }
    return locations;
  }

  Future<List<Character>> getCharacters() async {
    final data = await databaseProvider.readData('characters/');
    if (data.value == null) {
      return [];
    }
    final characters = <Character>[];
    if (data.value != null) {
      (data.value as Map).forEach((key, value) {
        characters.add(Character.fromJson(value));
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
      (data.value as Map).forEach((key, value) {
        entries.add(BulletPoint.fromJson(value));
      });
    }
    return Adventure(entries: entries);
  }

  Future<void> updateCampaign(
      String campaignId, Map<String, dynamic> campaignData) async {
    await databaseProvider.updateData('campaigns/$campaignId', campaignData);
  }

  Future<void> deleteCampaign(String campaignId) async {
    await databaseProvider.deleteData('campaigns/$campaignId');
  }

  Stream<DatabaseEvent> watchCampaign(String campaignId) {
    return databaseProvider.onValueStream('campaigns/$campaignId');
  }

  Stream<DatabaseEvent> watchAllCampaigns() {
    return databaseProvider.onValueStream('campaigns/');
  }
}
