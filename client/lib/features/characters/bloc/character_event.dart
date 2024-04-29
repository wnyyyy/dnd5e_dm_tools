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

class UpdateCharacter extends CharacterEvent {
  final Map<String, dynamic> character;
  final Map<String, dynamic> race;
  final Map<String, dynamic> classs;
  final String name;
  const UpdateCharacter({
    required this.character,
    required this.race,
    required this.classs,
    required this.name,
  });

  @override
  List<Object> get props => [character];
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
