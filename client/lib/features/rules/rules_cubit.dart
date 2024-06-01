import 'package:dnd5e_dm_tools/core/data/repositories/classes_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/conditions_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/feats_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/items_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/races_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/spells_repository.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RulesCubit extends Cubit<RulesState> {
  RulesCubit({
    required this.conditionsRepository,
    required this.racesRepository,
    required this.featsRepository,
    required this.classesRepository,
    required this.spellsRepository,
    required this.itemsRepository,
  }) : super(RulesStateInitial());
  final ConditionsRepository conditionsRepository;
  final RacesRepository racesRepository;
  final FeatsRepository featsRepository;
  final ClassesRepository classesRepository;
  final SpellsRepository spellsRepository;
  final ItemsRepository itemsRepository;

  Future<void> loadRules() async {
    emit(RulesStateLoading());
    var results = [];
    try {
      final conditions =
          conditionsRepository.getAll() as Future<Map<String, dynamic>>;
      final races = racesRepository.getAll() as Future<Map<String, dynamic>>;
      final classes =
          classesRepository.getAll() as Future<Map<String, dynamic>>;
      final spells = spellsRepository.getAll() as Future<Map<String, dynamic>>;
      final feats = featsRepository.getAll() as Future<Map<String, dynamic>>;
      final spellLists =
          spellsRepository.getSpellLists() as Future<Map<String, dynamic>>;
      final items = itemsRepository.getAll() as Future<Map<String, dynamic>>;
      results = await Future.wait([
        conditions,
        races,
        classes,
        spells,
        feats,
        spellLists,
        items,
      ]);
    } catch (e) {
      emit(RulesStateError(e.toString()));
    }
    try {
      emit(
        RulesStateLoaded(
          conditions: results[0] as Map<String, dynamic>,
          races: results[1] as Map<String, dynamic>,
          classes: results[2] as Map<String, dynamic>,
          spells: results[3] as Map<String, dynamic>,
          feats: results[4] as Map<String, dynamic>,
          spellLists: results[5] as Map<String, dynamic>,
          items: results[6] as Map<String, dynamic>,
        ),
      );
    } catch (e) {
      emit(RulesStateError(e.toString()));
    }
  }

  Map<String, dynamic>? getRace(String slug) {
    if (state is RulesStateLoaded) {
      return (state as RulesStateLoaded).races[slug] as Map<String, dynamic>;
    }
    return null;
  }

  Map<String, dynamic>? getClass(String slug) {
    if (state is RulesStateLoaded) {
      return (state as RulesStateLoaded).classes[slug] as Map<String, dynamic>;
    }
    return null;
  }

  Map<String, dynamic>? getFeat(String slug) {
    if (state is RulesStateLoaded) {
      return (state as RulesStateLoaded).feats[slug] as Map<String, dynamic>;
    }
    return null;
  }

  Map<String, dynamic> getAllFeats() {
    if (state is RulesStateLoaded) {
      return (state as RulesStateLoaded).feats;
    }
    return {};
  }

  Map<String, dynamic> getAllSpells() {
    if (state is RulesStateLoaded) {
      return (state as RulesStateLoaded).spells;
    }
    return {};
  }

  Map<String, dynamic>? getSpell(String slug) {
    if (state is RulesStateLoaded) {
      return (state as RulesStateLoaded).spells[slug] as Map<String, dynamic>;
    }
    return null;
  }

  Map<String, dynamic> getSpellsByClass(String classs) {
    if (state is RulesStateLoaded) {
      final Map<String, Map<String, dynamic>> spellList = {};
      final stateCast = state as RulesStateLoaded;
      final allSpells = stateCast.spells;
      final extraSuffix = ['a5e'];
      var classSpellListEntry = getClass(classs)?['spell_list'];
      classSpellListEntry ??= classs;
      final classSpellList = (stateCast.spellLists[classSpellListEntry]
              as Map?)?['spells'] as List<String>? ??
          [];
      for (final spell in classSpellList) {
        spellList[spell] = (allSpells[spell] as Map<String, dynamic>?) ?? {};
        for (final suffix in extraSuffix) {
          final extraSpell =
              allSpells['$spell-$suffix'] as Map<String, dynamic>? ?? {};
          if (extraSpell.isNotEmpty) {
            spellList['$spell-$suffix'] = extraSpell;
          }
        }
      }
      return spellList;
    }
    return {};
  }

  Map<String, dynamic>? getItem(String slug) {
    if (state is RulesStateLoaded) {
      return (state as RulesStateLoaded).items[slug] as Map<String, dynamic>;
    }
    return null;
  }

  Map<String, dynamic> getAllItems() {
    if (state is RulesStateLoaded) {
      return (state as RulesStateLoaded).items;
    }
    return {};
  }
}
