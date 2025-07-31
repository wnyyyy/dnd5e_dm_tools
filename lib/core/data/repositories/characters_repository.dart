import 'dart:async';

import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:logger/logger.dart';

class CharactersRepository {
  CharactersRepository(this.databaseProvider);
  final DatabaseProvider databaseProvider;
  final path = firebaseCharactersPath;
  Timer? _debounceTimer;
  final Duration _debounceDuration = const Duration(seconds: 30);

  Future<Character> get(String slug) async {
    final data = await databaseProvider.getDocument(path: '$path/$slug');
    if (data == null) {
      logRep('Character not found: $slug', level: Level.warning);
      throw Exception('Character not found');
    }
    final character = Character.fromJson(data, slug);
    return character;
  }

  Future<List<Character>> getAll() async {
    final List<Character> characters = [];
    final data = await databaseProvider.getCollection(path: path);
    for (final entry in data.entries) {
      final slug = entry.key;
      final characterData = entry.value;
      try {
        final character = Character.fromJson(characterData, slug);
        characters.add(character);
      } catch (e) {
        logRep('Error parsing character $slug: $e', level: Level.error);
      }
    }

    return characters;
  }

  Future<void> updateCharacter(Character character) async {
    logRep('Update call received. Timer reset.');
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () async {
      logRep('Timer expired. Updating character...');
      await databaseProvider.setData(
        path: '$path/${character.slug}',
        data: character.toJson(),
        offline: false,
      );
    });
  }
}
