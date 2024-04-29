import 'package:dnd5e_dm_tools/core/data/repositories/character_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/class_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/race_repository.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_event.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final CharacterRepository characterRepository;
  final RaceRepository raceRepository;
  final ClassRepository classRepository;
  final String name = '';

  CharacterBloc(
    this.characterRepository,
    this.raceRepository,
    this.classRepository,
  ) : super(CharacterStateInitial()) {
    on<CharacterLoad>(_onCharacterLoad);
    on<UpdateCharacter>(_onUpdateCharacter);
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
        character,
        name,
        race,
        classs,
      ));
    } catch (error) {
      emit(CharacterStateError("Failed to load characters"));
    }
  }

  Future<void> _onUpdateCharacter(
      UpdateCharacter event, Emitter<CharacterState> emit) async {
    emit(CharacterStateLoaded(
        event.character, event.name, event.classs, event.race));
    try {
      await characterRepository.updateCharacter(event.name, event.character);
    } catch (error) {
      emit(CharacterStateError("Failed to update character"));
    }
  }
}
