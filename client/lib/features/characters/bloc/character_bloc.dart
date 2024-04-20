import 'package:dnd5e_dm_tools/core/data/repositories/character_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/race_repository.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_event.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  final CharacterRepository characterRepository;
  final RaceRepository raceRepository;
  final String characterName;

  CharacterBloc(
      this.characterRepository, this.raceRepository, this.characterName)
      : super(CharacterStateInitial());
}
