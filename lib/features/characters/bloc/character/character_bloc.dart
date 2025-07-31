import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/characters_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/classes_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/items_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/races_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/spells_repository.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_event.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/web.dart';

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  CharacterBloc({
    required this.charactersRepository,
    required this.classesRepository,
    required this.racesRepository,
    required this.spellsRepository,
    required this.itemsRepository,
  }) : super(CharacterInitial()) {
    on<CharacterLoad>(_onCharacterLoad);
    on<CharacterUpdate>(_onCharacterUpdate);
    on<PersistCharacter>(_onPersistCharacter);
    on<CharacterPostLoad>(_onCharacterPostLoad);
  }
  final CharactersRepository charactersRepository;
  final ClassesRepository classesRepository;
  final RacesRepository racesRepository;
  final SpellsRepository spellsRepository;
  final ItemsRepository itemsRepository;

  Future<void> _onCharacterLoad(
    CharacterLoad event,
    Emitter<CharacterState> emit,
  ) async {
    logBloc('Loading char: ${event.slug}');
    emit(CharacterLoading(slug: event.slug));
    try {
      final Character character = await charactersRepository.get(
        event.slug.trim().toLowerCase(),
      );
      logBloc('Loading class for character: ${character.slug}');
      final Class classs = await classesRepository.get(character.classs);
      logBloc('Loading race for character: ${character.slug}');
      final Race race = await racesRepository.get(character.race);
      bool reloadItems = false;
      bool reloadSpells = false;
      if (character.spellbook.knownSpells.isNotEmpty) {
        logBloc('Loading spells for character: ${character.slug}');
        for (final spellSlug in character.spellbook.knownSpells) {
          final exists = await spellsRepository.existsInLocal(spellSlug);
          if (!exists) {
            reloadSpells = true;
          }
        }
      }
      if (character.backpack.items.isNotEmpty) {
        logBloc('Loading items for character: ${character.slug}');
        for (final item in character.backpack.items) {
          final exists = await itemsRepository.existsInLocal(item.itemSlug);
          if (!exists) {
            reloadItems = true;
          }
        }
      }
      emit(
        CharacterPostStart(
          character: character,
          classs: classs,
          race: race,
          reloadItems: reloadItems,
          reloadSpells: reloadSpells,
        ),
      );
    } catch (error) {
      logBloc(
        'Error loading character: ${event.slug} - $error',
        level: Level.error,
      );
      emit(
        CharacterError(
          error: 'Failed to load character ${event.slug} - $error',
          slug: event.slug,
        ),
      );
    }
  }

  Future<void> _onCharacterPostLoad(
    CharacterPostLoad event,
    Emitter<CharacterState> emit,
  ) async {
    if (state is! CharacterPostStart) {
      return;
    }
    final postStartState = state as CharacterPostStart;
    emit(
      CharacterLoaded(
        character: postStartState.character,
        classs: postStartState.classs,
        race: postStartState.race,
      ),
    );
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
