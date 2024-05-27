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
  final String slug;

  const CharacterLoading({
    required this.slug,
  });

  @override
  List<Object> get props => [slug];
}

class CharacterError extends CharacterState {
  final String slug;
  final String error;
  const CharacterError({
    required this.error,
    required this.slug,
  });

  @override
  List<Object> get props => [error, slug];
}

class CharacterLoaded extends CharacterState {
  final Map<String, dynamic> character;
  final String slug;
  const CharacterLoaded({
    required this.character,
    required this.slug,
  });

  CharacterLoaded copyWith(
      {Map<String, dynamic>? character,
      String? slug,
      Map<String, dynamic>? spells}) {
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
