import 'package:equatable/equatable.dart';

abstract class CharacterEvent extends Equatable {
  const CharacterEvent();

  @override
  List<Object> get props => [];
}

class CharacterLoad extends CharacterEvent {
  const CharacterLoad(this.characterName, {this.offline = false});
  final String characterName;
  final bool offline;

  @override
  List<Object> get props => [];
}

class CharacterUpdate extends CharacterEvent {
  const CharacterUpdate({
    required this.character,
    required this.slug,
    required this.offline,
    this.persistData = false,
  });
  final Map<String, dynamic> character;
  final String slug;
  final bool persistData;
  final bool offline;

  @override
  List<Object> get props => [
        character,
        slug,
      ];
}

class PersistCharacter extends CharacterEvent {
  const PersistCharacter({required this.offline});
  final bool offline;

  @override
  List<Object> get props => [offline];
}
