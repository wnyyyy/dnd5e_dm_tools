import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/models/update.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:logger/logger.dart';

class UpdatesRepository {
  UpdatesRepository(this.databaseProvider);
  final DatabaseProvider databaseProvider;

  Future<void> init() async {
    await databaseProvider.loadCache(cacheUpdatesName);
  }

  Future<List<Update>> getAll({required bool online}) async {
    final data = await databaseProvider.getCollection(
      path: firebaseUpdatesPath,
      cacheBoxName: online ? null : cacheUpdatesName,
    );
    final List<Update> updates = [];
    for (final entry in data.entries) {
      final id = entry.key;
      final data = entry.value;
      try {
        final update = Update.fromJson(data, id);
        updates.add(update);
      } catch (e) {
        logRep('Error parsing Update $id: $e', level: Level.error);
      }
    }
    return updates;
  }

  Future<void> set(List<Update> updates) async {
    for (final update in updates) {
      try {
        await databaseProvider.setData(
          path: '$firebaseUpdatesPath/${update.id}',
          data: update.toJson(),
          offline: true,
          cacheBoxName: cacheUpdatesName,
        );
      } catch (e) {
        logRep('Error saving Update ${update.id}: $e', level: Level.error);
      }
    }
  }

  Future<void> clearCache() async {
    await databaseProvider.clearCacheBox(cacheUpdatesName);
  }
}
