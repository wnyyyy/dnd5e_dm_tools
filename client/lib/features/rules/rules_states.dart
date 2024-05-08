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
  final String message;

  const RulesStateError(this.message);

  @override
  List<Object> get props => [message];
}

class RulesStateLoading extends RulesState {
  @override
  List<Object> get props => [];
}

class RulesStateLoaded extends RulesState {
  final Map<String, dynamic> races;
  final Map<String, dynamic> classes;
  final Map<String, dynamic> conditions;
  final Map<String, dynamic> feats;
  final Map<String, dynamic> spells;
  final Map<String, dynamic> spellLists;

  const RulesStateLoaded({
    required this.conditions,
    required this.races,
    required this.classes,
    required this.feats,
    required this.spells,
    required this.spellLists,
  });

  RulesStateLoaded copyWith({
    final Map<String, dynamic>? races,
    final Map<String, dynamic>? classes,
    final Map<String, dynamic>? conditions,
    final Map<String, dynamic>? feats,
    final Map<String, dynamic>? spells,
    final Map<String, dynamic>? spellLists,
  }) {
    return RulesStateLoaded(
      classes: classes ?? this.classes,
      conditions: conditions ?? this.conditions,
      races: races ?? this.races,
      feats: feats ?? this.feats,
      spells: spells ?? this.spells,
      spellLists: spells ?? this.spellLists,
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
      ];
}
