import 'package:dnd5e_dm_tools/core/data/models/backpack.dart';
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

class CharacterUpdateBackpack extends CharacterEvent {
  const CharacterUpdateBackpack({
    required this.character,
    required this.backpack,
  });
  final Character character;
  final Backpack backpack;

  @override
  List<Object> get props => [character, backpack];
}
