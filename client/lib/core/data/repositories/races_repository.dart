import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';

class RacesRepository {
  final DatabaseProvider databaseProvider;
  final path = 'races/';

  RacesRepository(this.databaseProvider);

  Future<void> init() async {
    await databaseProvider.loadCache(cacheRacesName);
  }

  Future<dynamic> get(String slug) async {
    final data = await databaseProvider.getDocument(
        path: '$path$slug', cacheBoxName: cacheRacesName);
    return data;
  }

  Future<Map<String, Map<String, dynamic>>> getAll() async {
    final data = await databaseProvider.getCollection(
        path: path, cacheBoxName: cacheRacesName);
    return data;
  }
}
