import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/models/condition.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:logger/logger.dart';

class ConditionsRepository {
  ConditionsRepository(this.databaseProvider);
  final DatabaseProvider databaseProvider;

  Future<void> init() async {
    await databaseProvider.loadCache(cacheConditionsName);
  }

  Future<List<Condition>> getAll() async {
    final data = await databaseProvider.getCollection(
      path: firebaseConditionsPath,
      cacheBoxName: cacheConditionsName,
    );
    final List<Condition> conditions = [];
    for (final entry in data.entries) {
      final slug = entry.key;
      final conditionData = entry.value;
      try {
        final condition = Condition.fromJson(conditionData, slug);
        conditions.add(condition);
      } catch (e) {
        logRep('Error parsing class $slug: $e', level: Level.error);
      }
    }
    return conditions;
  }
}
