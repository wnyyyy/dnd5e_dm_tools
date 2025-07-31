import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';
import 'package:equatable/equatable.dart';

abstract class CharacterState extends Equatable {
  const CharacterState();

  @override
  List<Object> get props => [];
}

class CharacterInitial extends CharacterState {
  @override
  List<Object> get props => [];
}

class CharacterLoading extends CharacterState {
  const CharacterLoading({required this.slug});
  final String slug;

  @override
  List<Object> get props => [slug];
}

class CharacterPostStart extends CharacterState {
  const CharacterPostStart({
    required this.character,
    required this.classs,
    required this.race,
    required this.reloadItems,
    required this.reloadSpells,
  });
  final Character character;
  final Class classs;
  final Race race;
  final bool reloadItems;
  final bool reloadSpells;

  CharacterPostStart copyWith({
    Character? character,
    Class? classs,
    Race? race,
    bool? reloadItems,
    bool? reloadSpells,
  }) {
    return CharacterPostStart(
      character: character ?? this.character,
      classs: classs ?? this.classs,
      race: race ?? this.race,
      reloadItems: reloadItems ?? this.reloadItems,
      reloadSpells: reloadSpells ?? this.reloadSpells,
    );
  }

  @override
  List<Object> get props => [
    character,
    classs,
    race,
    reloadItems,
    reloadSpells,
  ];
}

class CharacterError extends CharacterState {
  const CharacterError({required this.error, required this.slug});
  final String slug;
  final String error;

  @override
  List<Object> get props => [error, slug];
}

class CharacterLoaded extends CharacterState {
  const CharacterLoaded({
    required this.character,
    required this.classs,
    required this.race,
  });
  final Character character;
  final Class classs;
  final Race race;

  CharacterLoaded copyWith({Character? character, Class? classs, Race? race}) {
    return CharacterLoaded(
      character: character ?? this.character,
      classs: classs ?? this.classs,
      race: race ?? this.race,
    );
  }

  @override
  List<Object> get props => [character, classs, race];
}
