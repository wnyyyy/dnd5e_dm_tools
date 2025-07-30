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
    final spells = results[1] as List<Spell>;
    final weapons = itemList.whereType<Weapon>().toList();
    final armors = itemList.whereType<Armor>().toList();
    final weaponTemplates = itemList.whereType<WeaponTemplate>().toList();
    final genericItems = itemList.whereType<GenericItem>().toList();
    final itemMap = {for (final item in itemList) item.slug: item};
    final spellMap = {for (final spell in spells) spell.slug: spell};
    final spellMapByLevel = <int, List<Spell>>{};
    for (final spell in spells) {
      spellMapByLevel.putIfAbsent(spell.level, () => []).add(spell);
    }

    try {
      logBloc('Rules loaded successfully');
      emit(
        RulesStateLoaded(
          conditions: results[0] as List<Condition>,
          spells: spells,
          feats: results[2] as List<Feat>,
          spellLists: results[3] as List<SpellList>,
          genericItems: genericItems,
          weaponTemplates: weaponTemplates,
          armors: armors,
          weapons: weapons,
          allItems: itemList,
          itemMap: itemMap,
          spellMap: spellMap,
          spellMapByLevel: spellMapByLevel,
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
          spellsRepository.getAll().then((spells) {
            final spellMap = {for (final spell in spells) spell.slug: spell};
            final spellMapByLevel = <int, List<Spell>>{};
            for (final spell in spells) {
              spellMapByLevel.putIfAbsent(spell.level, () => []).add(spell);
            }
            emit(
              currState.copyWith(
                spells: spells,
                spellMap: spellMap,
                spellMapByLevel: spellMapByLevel,
              ),
            );
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
            final weapons = items.whereType<Weapon>().toList();
            final armors = items.whereType<Armor>().toList();
            final weaponTemplates = items.whereType<WeaponTemplate>().toList();
            final genericItems = items.whereType<GenericItem>().toList();
            final itemMap = {for (final item in items) item.slug: item};
            emit(
              currState.copyWith(
                weapons: weapons,
                armors: armors,
                weaponTemplates: weaponTemplates,
                genericItems: genericItems,
                allItems: items,
                itemMap: itemMap,
              ),
            );
          });
        default:
          logBloc('Unknown rule type: $type', level: Level.warning);
          emit(RulesStateError('Unknown rule type: $type'));
          return Future.value();
      }
      emit(
        RulesStateLoaded(
          conditions: currState.conditions,
          feats: currState.feats,
          spells: currState.spells,
          spellLists: currState.spellLists,
          genericItems: currState.genericItems,
          weaponTemplates: currState.weaponTemplates,
          armors: currState.armors,
          weapons: currState.weapons,
          allItems: currState.allItems,
          itemMap: currState.itemMap,
          spellMap: currState.spellMap,
          spellMapByLevel: currState.spellMapByLevel,
        ),
      );
    }
    return Future.value();
  }

  Future<void> addCustomItem(Item item) async {
    if (state is RulesStateLoaded) {
      try {
        final prevState = state as RulesStateLoaded;
        emit(RulesStateLoading());
        await itemsRepository.save(item.slug, item, false);
        final updatedItems = await itemsRepository.getAll();
        final weapons = updatedItems.whereType<Weapon>().toList();
        final armors = updatedItems.whereType<Armor>().toList();
        final weaponTemplates = updatedItems
            .whereType<WeaponTemplate>()
            .toList();
        final genericItems = updatedItems.whereType<GenericItem>().toList();
        final itemMap = {for (final item in updatedItems) item.slug: item};
        emit(
          RulesStateLoaded(
            conditions: prevState.conditions,
            feats: prevState.feats,
            spells: prevState.spells,
            spellLists: prevState.spellLists,
            genericItems: genericItems,
            weaponTemplates: weaponTemplates,
            armors: armors,
            weapons: weapons,
            allItems: updatedItems,
            itemMap: itemMap,
            spellMap: prevState.spellMap,
            spellMapByLevel: prevState.spellMapByLevel,
          ),
        );
      } catch (e) {
        logBloc('Error adding custom item: $e', level: Level.error);
        emit(RulesStateError('Failed to add custom item: $e'));
      }
    } else {
      logBloc('Cannot add custom item, rules not loaded', level: Level.warning);
    }
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
