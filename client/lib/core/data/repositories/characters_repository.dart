import 'dart:async';

import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';

class CharactersRepository {

  CharactersRepository(this.databaseProvider);
  final DatabaseProvider databaseProvider;
  final path = 'characters/';
  Timer? _debounceTimer;
  final Duration _debounceDuration = const Duration(seconds: 5);

  Future<void> init() async {
    await databaseProvider.loadCache(cacheCharacterName);
  }

  Future<dynamic> get(String slug, bool offline) async {
    if (offline) {
      return await databaseProvider.getDocument(
          path: '$path$slug', cacheBoxName: cacheCharacterName,);
    }
    final data = await databaseProvider.getDocument(path: '$path$slug');
    return data;
  }

  Future<Map<String, Map<String, dynamic>>> getAll() async {
    final data = await databaseProvider.getCollection(path: path);
    return data;
  }

  Future<void> updateCharacter(
    String slug,
    Map<String, dynamic> character,
    bool offline,
  ) async {
    print('Update call received. Timer reset.');
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () async {
      print('Timer expired. Updating character...');
      await databaseProvider.setData(
        path: '$path$slug',
        data: character,
        offline: offline,
        cacheBoxName: cacheCharacterName,
      );
    });
  }
}
