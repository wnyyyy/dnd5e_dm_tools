import 'package:dnd5e_dm_tools/core/data/repositories/characters_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/classes_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/feats_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/races_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/spells_repository.dart';
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
    on<ToggleEditingFeats>(_onToggleEditingFeats);
    on<ToggleEditingProf>(_onToggleEditingProf);
    on<LoadSpells>(_onLoadSpells);
  }

  Future<void> _onCharacterLoad(
      CharacterLoad event, Emitter<CharacterState> emit) async {
    print("Loading name: ${event.characterName}");
    emit(CharacterStateLoading());
    try {
      final name = event.characterName;
      Map<String, dynamic> character = await charactersRepository.get(name);
      emit(CharacterStateLoaded(
        character: character,
        name: name,
      ));
    } catch (error) {
      emit(const CharacterStateError("Failed to load characters"));
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
          event.name,
          event.character,
        );
      }
    } catch (error) {
      emit(const CharacterStateError("Failed to update character"));
    }
  }

  Future<void> _onPersistCharacter(
      PersistCharacter event, Emitter<CharacterState> emit) async {
    try {
      if (this.state is! CharacterStateLoaded) {
        return;
      }
      final state = this.state as CharacterStateLoaded;
      await charactersRepository.updateCharacter(
        state.name,
        state.character,
      );
    } catch (error) {
      emit(const CharacterStateError("Failed to persist character"));
    }
  }

  Future<void> _onToggleEditingFeats(
      ToggleEditingFeats event, Emitter<CharacterState> emit) async {
    try {
      if (state is! CharacterStateLoaded) {
        return;
      }
      final currState = state as CharacterStateLoaded;
      if (currState.availableFeats != null) {
        return;
      }
      final feats = await featRepository.getAll();
      final newState = currState.copyWith(
        availableFeats: feats,
        editingFeats: !currState.editingFeats,
      );
      emit(newState);
    } catch (error) {
      emit(const CharacterStateError("Failed to load feats"));
    }
  }

  Future<void> _onToggleEditingProf(
      ToggleEditingProf event, Emitter<CharacterState> emit) async {
    if (state is! CharacterStateLoaded) {
      return;
    }
    final currState = state as CharacterStateLoaded;
    emit(currState.copyWith(editingProf: !currState.editingProf));
  }

  Future<void> _onLoadSpells(
      LoadSpells event, Emitter<CharacterState> emit) async {
    if (state is! CharacterStateLoaded) {
      return;
    }
    final currState = state as CharacterStateLoaded;
    final Map<String, Map<String, dynamic>> spells;
    if (event.classSlug == null) {
      spells = await spellsRepository.getAll();
    } else {
      spells = await spellsRepository.getByClass(event.classSlug!);
    }
    emit(currState.copyWith(spells: spells));
  }
}
