import 'package:dnd5e_dm_tools/core/data/repositories/character_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/race_repository.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_event.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final CharacterRepository characterRepository;
  final RaceRepository raceRepository;

  CharacterBloc(this.characterRepository, this.raceRepository)
      : super(CharacterStateInitial()) {
    on<CharacterLoad>(_onCharacterLoad);
  }

  Future<void> _onCharacterLoad(
      CharacterLoad event, Emitter<CharacterState> emit) async {
    try {
      final name = event.characterName;
      var character = await characterRepository.get(name);
      if (character != null) {
        emit(CharacterStateLoaded(character));
        return;
      }
    } catch (error) {
      emit(CharacterStateError("Failed to load characters"));
    }
  }
}
