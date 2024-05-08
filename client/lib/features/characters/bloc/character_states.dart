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
  final String slug;

  const CharacterStateLoading({
    required this.slug,
  });

  @override
  List<Object> get props => [slug];
}

class CharacterStateError extends CharacterState {
  final String slug;
  final String error;
  const CharacterStateError({
    required this.error,
    required this.slug,
  });

  @override
  List<Object> get props => [error, slug];
}

class CharacterStateLoaded extends CharacterState {
  final Map<String, dynamic> character;
  final String slug;
  const CharacterStateLoaded({
    required this.character,
    required this.slug,
  });

  CharacterStateLoaded copyWith(
      {Map<String, dynamic>? character,
      String? slug,
      Map<String, dynamic>? spells}) {
    return CharacterStateLoaded(
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
