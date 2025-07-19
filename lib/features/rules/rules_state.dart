import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/data/models/condition.dart';
import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
import 'package:dnd5e_dm_tools/core/data/models/item.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';
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
    required this.items,
  });
  final List<Condition> conditions;
  final List<Feat> feats;
  final List<Spell> spells;
  final List<SpellList> spellLists;
  final List<Item> items;

  RulesStateLoaded copyWith({
    List<Race>? races,
    List<Class>? classes,
    List<Condition>? conditions,
    List<Feat>? feats,
    List<Spell>? spells,
    List<SpellList>? spellLists,
    List<Item>? items,
  }) {
    return RulesStateLoaded(
      conditions: conditions ?? this.conditions,
      feats: feats ?? this.feats,
      spells: spells ?? this.spells,
      spellLists: spellLists ?? this.spellLists,
      items: items ?? this.items,
    );
  }

  @override
  List<Object> get props => [conditions, feats, spells, spellLists, items];
}
