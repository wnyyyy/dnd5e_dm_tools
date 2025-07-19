import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/data/models/condition.dart';
import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
import 'package:dnd5e_dm_tools/core/data/models/item.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';
import 'package:dnd5e_dm_tools/core/data/models/spell.dart';
import 'package:dnd5e_dm_tools/core/data/models/spell_list.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/classes_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/conditions_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/feats_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/items_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/races_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/spells_repository.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

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
      logBloc('Loading rules...');
      final conditions = conditionsRepository.getAll();
      final races = racesRepository.getAll();
      final classes = classesRepository.getAll();
      final spells = spellsRepository.getAll();
      final feats = featsRepository.getAll();
      final spellLists = spellsRepository.getSpellLists();
      final items = itemsRepository.getAll();
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
      logBloc('Error loading rules: $e', level: Level.error);
      emit(RulesStateError(e.toString()));
    }
    try {
      logBloc('Rules loaded successfully');
      emit(
        RulesStateLoaded(
          conditions: results[0] as List<Condition>,
          races: results[1] as List<Race>,
          classes: results[2] as List<Class>,
          feats: results[3] as List<Feat>,
          spells: results[4] as List<Spell>,
          spellLists: results[5] as List<SpellList>,
          items: results[6] as List<Item>,
        ),
      );
    } catch (e) {
      logBloc('Error processing loaded rules: $e', level: Level.error);
      emit(RulesStateError(e.toString()));
    }
  }

  Future<void> reloadRule(String type) {
    if (state is RulesStateLoaded) {
      final currState = state as RulesStateLoaded;
      emit(RulesStateLoading());
      switch (type) {
        case 'conditions':
          conditionsRepository.getAll().then((conditions) {
            emit(currState.copyWith(conditions: conditions));
          });
          return Future.value();
        case 'races':
          racesRepository.getAll().then((races) {
            emit(currState.copyWith(races: races));
          });
          return Future.value();
        case 'classes':
          classesRepository.getAll().then((classes) {
            emit(currState.copyWith(classes: classes));
          });
          return Future.value();
        case 'spells':
          spellsRepository.getAll().then((spells) {
            emit(currState.copyWith(spells: spells));
          });
          return Future.value();
        case 'feats':
          featsRepository.getAll().then((feats) {
            emit(currState.copyWith(feats: feats));
          });
          return Future.value();
        case 'spellLists':
          spellsRepository.getSpellLists().then((spellLists) {
            emit(currState.copyWith(spellLists: spellLists));
          });
          return Future.value();
        case 'items':
          itemsRepository.getAll().then((items) {
            emit(currState.copyWith(items: items));
          });
          return Future.value();
        default:
          return Future.value();
      }
    }
    return Future.value();
  }
}
