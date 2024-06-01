import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';

class ConditionsRepository {

  ConditionsRepository(this.databaseProvider);
  final DatabaseProvider databaseProvider;
  final path = 'conditions/';

  Future<void> init() async {
    await databaseProvider.loadCache(cacheConditionsName);
  }

  Future<Map<String, Map<String, dynamic>>> getAll() async {
    final data = await databaseProvider.getCollection(
        path: path, cacheBoxName: cacheConditionsName,);
    return data;
  }
}
