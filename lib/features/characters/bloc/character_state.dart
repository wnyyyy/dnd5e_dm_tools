import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
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

class CharacterError extends CharacterState {
  const CharacterError({required this.error, required this.slug});
  final String slug;
  final String error;

  @override
  List<Object> get props => [error, slug];
}

class CharacterLoaded extends CharacterState {
  const CharacterLoaded({required this.character, required this.classs});
  final Character character;
  final Class classs;

  CharacterLoaded copyWith({Character? character, Class? classs}) {
    return CharacterLoaded(
      character: character ?? this.character,
      classs: classs ?? this.classs,
    );
  }
}
