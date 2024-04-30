import 'package:dnd5e_dm_tools/core/data/repositories/character_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/class_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/feat_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/race_repository.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final CharacterRepository characterRepository;
  final RaceRepository raceRepository;
  final ClassRepository classRepository;
  final FeatRepository featRepository;
  final String name = '';

  CharacterBloc(
    this.characterRepository,
    this.raceRepository,
    this.classRepository,
    this.featRepository,
  ) : super(CharacterStateInitial()) {
    on<CharacterLoad>(_onCharacterLoad);
    on<CharacterUpdate>(_onCharacterUpdate);
    on<PersistCharacter>(_onPersistCharacter);
    on<ToggleEditingFeats>(_onToggleEditingFeats);
    on<ToggleEditingProf>(_onToggleEditingProf);
  }

  Future<void> _onCharacterLoad(
      CharacterLoad event, Emitter<CharacterState> emit) async {
    print("Loading name: ${event.characterName}");
    emit(CharacterStateLoading());
    try {
      final name = event.characterName;
      Map<String, dynamic> character = await characterRepository.get(name);
      Map<String, dynamic> race = await raceRepository.get(character['race']);
      Map<String, dynamic> classs =
          await classRepository.get(character['class']);
      emit(CharacterStateLoaded(
        character: character,
        name: name,
        race: race,
        classs: classs,
      ));
    } catch (error) {
      emit(CharacterStateError("Failed to load characters"));
    }
  }

  Future<void> _onCharacterUpdate(
      CharacterUpdate event, Emitter<CharacterState> emit) async {
    try {
      if (this.state is! CharacterStateLoaded) {
        return;
      }
      var character = Map.from(event.character).cast<String, dynamic>();
      var newState = (this.state as CharacterStateLoaded).copyWith(
        character: character,
      );

      emit(newState);
      if (event.persistData) {
        await characterRepository.updateCharacter(
          event.name,
          event.character,
        );
      }
    } catch (error) {
      emit(CharacterStateError("Failed to update character"));
    }
  }

  Future<void> _onPersistCharacter(
      PersistCharacter event, Emitter<CharacterState> emit) async {
    try {
      if (this.state is! CharacterStateLoaded) {
        return;
      }
      final state = this.state as CharacterStateLoaded;
      await characterRepository.updateCharacter(
        state.name,
        state.character,
      );
    } catch (error) {
      emit(CharacterStateError("Failed to persist character"));
    }
  }

  Future<void> _onToggleEditingFeats(
      ToggleEditingFeats event, Emitter<CharacterState> emit) async {
    try {
      if (this.state is! CharacterStateLoaded) {
        return;
      }
      final currState = this.state as CharacterStateLoaded;
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
      emit(CharacterStateError("Failed to load feats"));
    }
  }

  Future<void> _onToggleEditingProf(
      ToggleEditingProf event, Emitter<CharacterState> emit) async {
    if (this.state is! CharacterStateLoaded) {
      return;
    }
    final currState = this.state as CharacterStateLoaded;
    emit(currState.copyWith(editingProf: !currState.editingProf));
  }
}
