import 'package:dnd5e_dm_tools/core/data/models/condition.dart';
import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
import 'package:dnd5e_dm_tools/core/data/models/item.dart';
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
    required this.featsRepository,
    required this.spellsRepository,
    required this.itemsRepository,
    required this.classesRepository,
    required this.racesRepository,
  }) : super(RulesStateInitial());
  final ConditionsRepository conditionsRepository;
  final FeatsRepository featsRepository;
  final SpellsRepository spellsRepository;
  final ItemsRepository itemsRepository;
  final ClassesRepository classesRepository;
  final RacesRepository racesRepository;

  Future<void> loadRules() async {
    emit(RulesStateLoading());

    await spellsRepository.init();
    await featsRepository.init();
    await conditionsRepository.init();
    await itemsRepository.init();
    await classesRepository.init();
    await racesRepository.init();

    var results = [];
    try {
      logBloc('Loading rules...');
      final conditions = conditionsRepository.getAll();
      final spells = spellsRepository.getAll();
      final feats = featsRepository.getAll();
      final spellLists = spellsRepository.getSpellLists();
      final items = itemsRepository.getAll();
      results = await Future.wait([
        conditions,
        spells,
        feats,
        spellLists,
        items,
      ]);
    } catch (e) {
      logBloc('Error loading rules: $e', level: Level.error);
      emit(RulesStateError(e.toString()));
    }
    final itemList = results[4] as List<Item>;
    final weapons = itemList.whereType<Weapon>().toList();
    final armors = itemList.whereType<Armor>().toList();
    final weaponTemplates = itemList.whereType<WeaponTemplate>().toList();
    final genericItems = itemList.whereType<GenericItem>().toList();

    try {
      logBloc('Rules loaded successfully');
      emit(
        RulesStateLoaded(
          conditions: results[0] as List<Condition>,
          spells: results[1] as List<Spell>,
          feats: results[2] as List<Feat>,
          spellLists: results[3] as List<SpellList>,
          genericItems: genericItems,
          weaponTemplates: weaponTemplates,
          armors: armors,
          weapons: weapons,
          allItems: itemList,
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
        case 'spells':
          spellsRepository.getAll(online: true).then((spells) {
            emit(currState.copyWith(spells: spells));
          });
          return Future.value();
        case 'feats':
          featsRepository.getAll(online: true).then((feats) {
            emit(currState.copyWith(feats: feats));
          });
          return Future.value();
        case 'spellLists':
          spellsRepository.getSpellLists().then((spellLists) {
            emit(currState.copyWith(spellLists: spellLists));
          });
          return Future.value();
        case 'items':
          itemsRepository.getAll(online: true).then((items) {
            final weapons = items.whereType<Weapon>().toList();
            final armors = items.whereType<Armor>().toList();
            final weaponTemplates = items.whereType<WeaponTemplate>().toList();
            final genericItems = items.whereType<GenericItem>().toList();
            emit(
              currState.copyWith(
                weapons: weapons,
                armors: armors,
                weaponTemplates: weaponTemplates,
                genericItems: genericItems,
                allItems: items,
              ),
            );
          });
        default:
          logBloc('Unknown rule type: $type', level: Level.warning);
          emit(RulesStateError('Unknown rule type: $type'));
          return Future.value();
      }
    }
    return Future.value();
  }

  Future<void> invalidateCache(List<String> types) async {
    emit(RulesStateLoading());
    for (final type in types) {
      switch (type) {
        case 'feats':
          await featsRepository.clearCache();
        case 'races':
          await racesRepository.clearCache();
        case 'spells':
          await spellsRepository.clearCache();
        case 'classes':
          await classesRepository.clearCache();
        case 'items':
          await itemsRepository.clearCache();
      }
    }
    emit(RulesStatePendingRestart());
  }
}
