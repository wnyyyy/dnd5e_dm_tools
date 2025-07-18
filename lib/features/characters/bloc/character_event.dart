import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:equatable/equatable.dart';

abstract class CharacterEvent extends Equatable {
  const CharacterEvent();

  @override
  List<Object> get props => [];
}

class CharacterLoad extends CharacterEvent {
  const CharacterLoad(this.slug);
  final String slug;

  @override
  List<Object> get props => [];
}

class CharacterUpdate extends CharacterEvent {
  const CharacterUpdate({required this.character, this.persistData = false});
  final Character character;
  final bool persistData;

  @override
  List<Object> get props => [character];
}

class PersistCharacter extends CharacterEvent {
  const PersistCharacter();
}
