import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/characters_repository.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_event.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/web.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  CharacterBloc({required this.charactersRepository})
    : super(CharacterInitial()) {
    on<CharacterLoad>(_onCharacterLoad);
    on<CharacterUpdate>(_onCharacterUpdate);
    on<PersistCharacter>(_onPersistCharacter);
  }
  final CharactersRepository charactersRepository;

  Future<void> _onCharacterLoad(
    CharacterLoad event,
    Emitter<CharacterState> emit,
  ) async {
    logBloc('Loading char: ${event.slug}');
    emit(CharacterLoading(slug: event.slug));
    try {
      final Character character = await charactersRepository.get(event.slug);
      emit(CharacterLoaded(character: character));
    } catch (error) {
      logBloc(
        'Error loading character: ${event.slug} - $error',
        level: Level.error,
      );
      emit(
        CharacterError(
          error: 'Failed to load character $event.slug',
          slug: event.slug,
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
      logBloc('Updating character: ${event.character.slug}');
      final newState = (state as CharacterLoaded).copyWith(
        character: event.character,
      );

      emit(newState);
      if (event.persistData) {
        logBloc('Persisting character: ${event.character.slug}');
        await charactersRepository.updateCharacter(event.character);
      }
    } catch (error) {
      logBloc(
        'Error updating character: ${event.character.slug} - $error',
        level: Level.error,
      );
      emit(
        CharacterError(
          error: 'Failed to update character',
          slug: event.character.slug,
        ),
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
    logBloc('Persisting character data for slug: $state.character.slug');
    try {
      await charactersRepository.updateCharacter(state.character);
    } catch (error) {
      logBloc(
        'Error persisting character: ${state.character.slug} - $error',
        level: Level.error,
      );
      emit(
        CharacterError(
          error: 'Failed to persist character',
          slug: state.character.slug,
        ),
      );
    }
  }
}
