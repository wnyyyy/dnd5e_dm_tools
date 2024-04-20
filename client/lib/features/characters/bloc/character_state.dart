import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:equatable/equatable.dart';

abstract class CharacterState extends Equatable {
  const CharacterState();

  @override
  List<Object> get props => [];
}

class CharacterStateInitial extends CharacterState {
  @override
  List<Object> get props => [];
}

class CharacterStateLoading extends CharacterState {
  @override
  List<Object> get props => [];
}

class CharacterStateError extends CharacterState {
  final String error;
  const CharacterStateError(this.error);

  @override
  List<Object> get props => [error];
}

class CharacterStateLoaded extends CharacterState {
  final Character character;
  const CharacterStateLoaded(this.character);

  @override
  List<Object> get props => [character];
}
