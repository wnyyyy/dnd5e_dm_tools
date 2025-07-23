import 'package:dnd5e_dm_tools/core/data/models/condition.dart';
import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
import 'package:dnd5e_dm_tools/core/data/models/item.dart';
import 'package:dnd5e_dm_tools/core/data/models/spell.dart';
import 'package:dnd5e_dm_tools/core/data/models/spell_list.dart';
import 'package:equatable/equatable.dart';

abstract class RulesState extends Equatable {
  const RulesState();

  @override
  List<Object> get props => [];
}

class RulesStateInitial extends RulesState {
  @override
  List<Object> get props => [];
}

class RulesStateError extends RulesState {
  const RulesStateError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

class RulesStatePendingRestart extends RulesState {
  @override
  List<Object> get props => [];
}

class RulesStateLoading extends RulesState {
  @override
  List<Object> get props => [];
}

class RulesStateLoaded extends RulesState {
  const RulesStateLoaded({
    required this.conditions,
    required this.feats,
    required this.spells,
    required this.spellLists,
    required this.genericItems,
    required this.weaponTemplates,
    required this.armors,
    required this.weapons,
    required this.allItems,
  });
  final List<Condition> conditions;
  final List<Feat> feats;
  final List<Spell> spells;
  final List<SpellList> spellLists;
  final List<GenericItem> genericItems;
  final List<WeaponTemplate> weaponTemplates;
  final List<Armor> armors;
  final List<Weapon> weapons;
  final List<Item> allItems;

  RulesStateLoaded copyWith({
    List<Condition>? conditions,
    List<Feat>? feats,
    List<Spell>? spells,
    List<SpellList>? spellLists,
    List<WeaponTemplate>? weaponTemplates,
    List<Armor>? armors,
    List<Weapon>? weapons,
    List<GenericItem>? genericItems,
    List<Item>? allItems,
  }) {
    return RulesStateLoaded(
      conditions: conditions ?? this.conditions,
      feats: feats ?? this.feats,
      spells: spells ?? this.spells,
      spellLists: spellLists ?? this.spellLists,
      genericItems: genericItems ?? this.genericItems,
      weaponTemplates: weaponTemplates ?? this.weaponTemplates,
      armors: armors ?? this.armors,
      weapons: weapons ?? this.weapons,
      allItems: allItems ?? this.allItems,
    );
  }

  @override
  List<Object> get props => [
    conditions,
    feats,
    spells,
    spellLists,
    genericItems,
    weaponTemplates,
    armors,
    weapons,
    allItems,
  ];
}
