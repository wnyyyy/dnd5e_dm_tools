import 'package:dnd5e_dm_tools/core/data/repositories/characters_repository.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  CharacterBloc({
    required this.charactersRepository,
  }) : super(CharacterInitial()) {
    on<CharacterLoad>(_onCharacterLoad);
    on<CharacterUpdate>(_onCharacterUpdate);
    on<PersistCharacter>(_onPersistCharacter);
  }
  final CharactersRepository charactersRepository;
  final String name = '';

  Future<void> _onCharacterLoad(
    CharacterLoad event,
    Emitter<CharacterState> emit,
  ) async {
    print('Loading name: ${event.characterName}');
    emit(CharacterLoading(slug: event.characterName));
    try {
      final slug = event.characterName;
      final Map<String, dynamic> character = await charactersRepository.get(
        slug,
        event.offline,
      ) as Map<String, dynamic>;
      emit(
        CharacterLoaded(
          character: character,
          slug: slug,
        ),
      );
    } catch (error) {
      emit(
        CharacterError(
          error: 'Failed to load characters',
          slug: event.characterName,
        ),
      );
    }
  }

  Future<void> _onCharacterUpdate(
    CharacterUpdate event,
    Emitter<CharacterState> emit,
  ) async {
    try {
      if (state is! CharacterLoaded) {
        return;
      }
      final character = Map.from(event.character).cast<String, dynamic>();
      final newState = (state as CharacterLoaded).copyWith(
        character: character,
      );

      emit(newState);
      if (event.persistData) {
        await charactersRepository.updateCharacter(
          event.slug,
          event.character,
          event.offline,
        );
      }
    } catch (error) {
      emit(
        CharacterError(error: 'Failed to load characters', slug: event.slug),
      );
    }
  }

  Future<void> _onPersistCharacter(
    PersistCharacter event,
    Emitter<CharacterState> emit,
  ) async {
    if (this.state is! CharacterLoaded) {
      return;
    }
    final state = this.state as CharacterLoaded;
    try {
      await charactersRepository.updateCharacter(
        state.slug,
        state.character,
        event.offline,
      );
    } catch (error) {
      emit(
        CharacterError(error: 'Failed to persist character', slug: state.slug),
      );
    }
  }
}
