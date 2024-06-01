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
    required this.races,
    required this.classes,
    required this.feats,
    required this.spells,
    required this.spellLists,
    required this.items,
  });
  final Map<String, dynamic> races;
  final Map<String, dynamic> classes;
  final Map<String, dynamic> conditions;
  final Map<String, dynamic> feats;
  final Map<String, dynamic> spells;
  final Map<String, dynamic> spellLists;
  final Map<String, dynamic> items;

  RulesStateLoaded copyWith({
    Map<String, dynamic>? races,
    Map<String, dynamic>? classes,
    Map<String, dynamic>? conditions,
    Map<String, dynamic>? feats,
    Map<String, dynamic>? spells,
    Map<String, dynamic>? spellLists,
    Map<String, dynamic>? items,
    Map<String, dynamic>? magicItems,
  }) {
    return RulesStateLoaded(
      classes: classes ?? this.classes,
      conditions: conditions ?? this.conditions,
      races: races ?? this.races,
      feats: feats ?? this.feats,
      spells: spells ?? this.spells,
      spellLists: spellLists ?? this.spellLists,
      items: items ?? this.items,
    );
  }

  @override
  List<Object> get props => [
        conditions,
        races,
        classes,
        feats,
        spells,
        spellLists,
        items,
      ];
}
