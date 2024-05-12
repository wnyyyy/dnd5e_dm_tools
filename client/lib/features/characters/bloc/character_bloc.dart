import 'package:dnd5e_dm_tools/core/data/repositories/characters_repository.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final CharactersRepository charactersRepository;
  final String name = '';

  CharacterBloc({
    required this.charactersRepository,
  }) : super(CharacterStateInitial()) {
    on<CharacterLoad>(_onCharacterLoad);
    on<CharacterUpdate>(_onCharacterUpdate);
    on<PersistCharacter>(_onPersistCharacter);
  }

  Future<void> _onCharacterLoad(
      CharacterLoad event, Emitter<CharacterState> emit) async {
    print("Loading name: ${event.characterName}");
    emit(CharacterStateLoading(slug: event.characterName));
    try {
      final slug = event.characterName;
      Map<String, dynamic> character =
          await charactersRepository.get(slug, event.offline);
      emit(
        CharacterStateLoaded(
          character: character,
          slug: slug,
        ),
      );
    } catch (error) {
      emit(
        CharacterStateError(
            error: "Failed to load characters", slug: event.characterName),
      );
    }
  }

  Future<void> _onCharacterUpdate(
      CharacterUpdate event, Emitter<CharacterState> emit) async {
    try {
      if (state is! CharacterStateLoaded) {
        return;
      }
      var character = Map.from(event.character).cast<String, dynamic>();
      var newState = (state as CharacterStateLoaded).copyWith(
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
        CharacterStateError(
            error: "Failed to load characters", slug: event.slug),
      );
    }
  }

  Future<void> _onPersistCharacter(
      PersistCharacter event, Emitter<CharacterState> emit) async {
    if (this.state is! CharacterStateLoaded) {
      return;
    }
    final state = this.state as CharacterStateLoaded;
    try {
      await charactersRepository.updateCharacter(
        state.slug,
        state.character,
        event.offline,
      );
    } catch (error) {
      emit(
        CharacterStateError(
            error: "Failed to persist character", slug: state.slug),
      );
    }
  }
}
