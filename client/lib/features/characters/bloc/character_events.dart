import 'package:equatable/equatable.dart';

abstract class CharacterEvent extends Equatable {
  const CharacterEvent();

  @override
  List<Object> get props => [];
}

class CharacterLoad extends CharacterEvent {
  final String characterName;
  final bool offline;
  const CharacterLoad(this.characterName, {this.offline = false});

  @override
  List<Object> get props => [];
}

class CharacterUpdate extends CharacterEvent {
  final Map<String, dynamic> character;
  final String slug;
  final bool persistData;
  final bool offline;
  const CharacterUpdate({
    required this.character,
    required this.slug,
    required this.offline,
    this.persistData = false,
  });

  @override
  List<Object> get props => [
        character,
        slug,
      ];
}

class PersistCharacter extends CharacterEvent {
  final bool offline;
  final bool online;
  const PersistCharacter({required this.offline, this.online = false});

  @override
  List<Object> get props => [offline, online];
}
