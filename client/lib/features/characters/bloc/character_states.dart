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

  const CharacterLoading({
    required this.slug,
  });
  final String slug;

  @override
  List<Object> get props => [slug];
}

class CharacterError extends CharacterState {
  const CharacterError({
    required this.error,
    required this.slug,
  });
  final String slug;
  final String error;

  @override
  List<Object> get props => [error, slug];
}

class CharacterLoaded extends CharacterState {
  const CharacterLoaded({
    required this.character,
    required this.slug,
  });
  final Map<String, dynamic> character;
  final String slug;

  CharacterLoaded copyWith(
      {Map<String, dynamic>? character,
      String? slug,
      Map<String, dynamic>? spells,}) {
    return CharacterLoaded(
      character: character ?? this.character,
      slug: slug ?? this.slug,
    );
  }

  @override
  List<Object> get props => [
        ...character.entries,
        slug,
      ];
}
