import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';

class CharactersRepository {
  final DatabaseProvider databaseProvider;
  final path = 'characters/';

  CharactersRepository(this.databaseProvider);

  Future<void> init() async {
    await databaseProvider.loadCache(cacheCharacterName);
  }

  Future<dynamic> get(String slug, bool offline) async {
    if (offline) {
      return await databaseProvider.getDocument(
          path: '$path$slug', cacheBoxName: cacheCharacterName);
    }
    final data = await databaseProvider.getDocument(path: '$path$slug');
    return data;
  }

  Future<void> updateCharacter(
    String slug,
    Map<String, dynamic> character,
    bool offline, {
    bool online = false,
  }) async {
    await databaseProvider.setData(
      path: '$path$slug',
      data: character,
      cacheBoxName: offline ? cacheCharacterName : null,
    );
    if (online) {
      await databaseProvider.setData(
        path: '$path$slug',
        data: character,
      );
    }
  }

  Future<Map<String, Map<String, dynamic>>> getAll() async {
    final data = await databaseProvider.getCollection(path: path);
    return data;
  }
}
