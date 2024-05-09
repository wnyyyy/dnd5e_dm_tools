import 'package:dnd5e_dm_tools/core/data/repositories/classes_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/conditions_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/feats_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/races_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/spells_repository.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RulesCubit extends Cubit<RulesState> {
  final ConditionsRepository conditionsRepository;
  final RacesRepository racesRepository;
  final FeatsRepository featsRepository;
  final ClassesRepository classesRepository;
  final SpellsRepository spellsRepository;
  RulesCubit({
    required this.conditionsRepository,
    required this.racesRepository,
    required this.featsRepository,
    required this.classesRepository,
    required this.spellsRepository,
  }) : super(RulesStateInitial());

  void loadRules() async {
    emit(RulesStateLoading());
    var results = [];
    try {
      final conditions = conditionsRepository.getAll();
      final races = racesRepository.getAll();
      final classes = classesRepository.getAll();
      final spells = spellsRepository.getAll();
      final feats = featsRepository.getAll();
      final spellLists = spellsRepository.getSpellLists();
      results = await Future.wait([
        conditions,
        races,
        classes,
        spells,
        feats,
        spellLists,
      ]);
    } catch (e) {
      emit(RulesStateError(e.toString()));
    }
    try {
      emit(
        RulesStateLoaded(
          conditions: results[0],
          races: results[1],
          classes: results[2],
          spells: results[3],
          feats: results[4],
          spellLists: results[5],
        ),
      );
    } catch (e) {
      emit(RulesStateError(e.toString()));
    }
  }

  Map<String, dynamic>? getRace(String slug) {
    if (state is RulesStateLoaded) {
      return (state as RulesStateLoaded).races[slug];
    }
    return null;
  }

  Map<String, dynamic>? getClass(String slug) {
    if (state is RulesStateLoaded) {
      return (state as RulesStateLoaded).classes[slug];
    }
    return null;
  }

  Map<String, dynamic>? getFeat(String slug) {
    if (state is RulesStateLoaded) {
      return (state as RulesStateLoaded).feats[slug];
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

  Map<String, dynamic> getSpellsByClass(String classs) {
    if (state is RulesStateLoaded) {
      Map<String, Map<String, dynamic>> spellList = {};
      final allSpells = (state as RulesStateLoaded).spells;
      final extraSuffix = ['a5e'];
      final classSpells =
          (state as RulesStateLoaded).spellLists[classs]['spells'];
      for (var spell in classSpells) {
        spellList[spell] = allSpells[spell] ?? {};
        for (var suffix in extraSuffix) {
          final extraSpell = allSpells['$spell-$suffix'];
          if (extraSpell != null) {
            spellList['$spell-$suffix'] = extraSpell;
          }
        }
      }
      return spellList;
    }
    return {};
  }
}
