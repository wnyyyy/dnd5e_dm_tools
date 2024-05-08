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
  final Map<String, dynamic>? feats;
  final Map<String, dynamic>? spells;

  const RulesStateLoaded({
    required this.conditions,
    required this.races,
    required this.classes,
    this.feats,
    this.spells,
  });

  RulesStateLoaded copyWith({
    final Map<String, dynamic>? races,
    final Map<String, dynamic>? classes,
    final Map<String, dynamic>? conditions,
    final Map<String, dynamic>? feats,
    final Map<String, dynamic>? spells,
  }) {
    return RulesStateLoaded(
      classes: classes ?? this.classes,
      conditions: conditions ?? this.conditions,
      races: races ?? this.races,
      feats: feats ?? this.feats,
      spells: spells ?? this.spells,
    );
  }

  @override
  List<Object> get props => [
        conditions,
        races,
        classes,
        ...feats?.values ?? [],
        ...spells?.values ?? [],
      ];
}
