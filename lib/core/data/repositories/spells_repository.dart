import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/models/spell.dart';
import 'package:dnd5e_dm_tools/core/data/models/spell_list.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:logger/logger.dart';

class SpellsRepository {
  SpellsRepository(this.databaseProvider);
  final DatabaseProvider databaseProvider;

  Future<void> init() async {
    await databaseProvider.loadCache(cacheSpellsName);
    await databaseProvider.loadCache(cacheSpellListsName);
  }

  Future<Spell> get(String slug) async {
    final data = await databaseProvider.getDocument(
      path: '$firebaseSpellsPath/$slug',
      cacheBoxName: cacheSpellsName,
    );
    if (data == null) {
      logRep('Spell not found: $slug', level: Level.warning);
      throw Exception('Spell not found');
    }
    final spell = Spell.fromJson(data, slug);
    return spell;
  }

  Future<List<Spell>> getAll() async {
    final data = await databaseProvider.getCollection(
      path: firebaseSpellsPath,
      cacheBoxName: cacheSpellsName,
    );
    final List<Spell> spells = [];
    for (final entry in data.entries) {
      final slug = entry.key;
      final spellData = entry.value;
      try {
        final spell = Spell.fromJson(spellData, slug);
        spells.add(spell);
      } catch (e) {
        logRep('Error parsing Spell $slug: $e', level: Level.error);
      }
    }
    return spells;
  }

  Future<List<SpellList>> getSpellLists() async {
    final data = await databaseProvider.getCollection(
      path: firebaseSpellListsPath,
      cacheBoxName: cacheSpellListsName,
    );
    final List<SpellList> spellLists = [];
    for (final entry in data.entries) {
      final slug = entry.key;
      final spellListData = entry.value;
      try {
        final spellList = SpellList.fromJson(spellListData, slug);
        spellLists.add(spellList);
      } catch (e) {
        logRep('Error parsing SpellList $slug: $e', level: Level.error);
      }
    }
    return spellLists;
  }

  Future<void> sync(String slug, Spell spell) async {
    final entry = spell.toJson();
    await databaseProvider.setData(
      path: slug,
      data: entry,
      offline: true,
      cacheBoxName: cacheSpellsName,
    );
  }

  Future<void> save(String slug, Spell spell, bool offline) async {
    final entry = spell.toJson();
    await databaseProvider.setData(
      path: '$firebaseSpellsPath/$slug',
      data: entry,
      offline: offline,
      cacheBoxName: cacheSpellsName,
    );
  }
}
