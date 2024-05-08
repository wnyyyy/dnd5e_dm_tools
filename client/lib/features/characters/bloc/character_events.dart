import 'package:equatable/equatable.dart';

abstract class CharacterEvent extends Equatable {
  const CharacterEvent();

  @override
  List<Object> get props => [];
}

class CharacterLoad extends CharacterEvent {
  final String characterName;
  const CharacterLoad(this.characterName);

  @override
  List<Object> get props => [];
}

class CharacterUpdate extends CharacterEvent {
  final Map<String, dynamic> character;
  final String slug;
  final bool persistData;
  const CharacterUpdate({
    required this.character,
    required this.slug,
    this.persistData = false,
  });

  @override
  List<Object> get props => [
        character,
        slug,
      ];
}

class PersistCharacter extends CharacterEvent {
  const PersistCharacter();

  @override
  List<Object> get props => [];
}
