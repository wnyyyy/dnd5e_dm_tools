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
  final String name;
  final bool persistData;
  const CharacterUpdate({
    required this.character,
    required this.name,
    this.persistData = false,
  });

  @override
  List<Object> get props => [
        character,
        name,
      ];
}

class ChangeFeats extends CharacterEvent {
  final List<String> featSlugs;
  const ChangeFeats(this.featSlugs);

  @override
  List<Object> get props => [featSlugs];
}

class ShowFeatDetails extends CharacterEvent {
  final String featSlug;
  const ShowFeatDetails(this.featSlug);

  @override
  List<Object> get props => [featSlug];
}

class PersistCharacter extends CharacterEvent {
  const PersistCharacter();

  @override
  List<Object> get props => [];
}

class ToggleEditingFeats extends CharacterEvent {
  const ToggleEditingFeats();

  @override
  List<Object> get props => [];
}

class ToggleEditingProf extends CharacterEvent {
  const ToggleEditingProf();

  @override
  List<Object> get props => [];
}

class LoadSpells extends CharacterEvent {
  final String? classSlug;
  const LoadSpells({this.classSlug});

  @override
  List<Object> get props => [classSlug ?? ''];
}
