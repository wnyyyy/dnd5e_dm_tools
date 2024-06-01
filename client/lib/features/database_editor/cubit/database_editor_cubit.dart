import 'package:dnd5e_dm_tools/core/data/repositories/characters_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/classes_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/feats_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/items_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/races_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/spells_repository.dart';
import 'package:dnd5e_dm_tools/features/database_editor/cubit/database_editor_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DatabaseEditorCubit extends Cubit<DatabaseEditorState> {
  DatabaseEditorCubit({
    required this.spellsRepository,
    required this.featsRepository,
    required this.classesRepository,
    required this.racesRepository,
    required this.itemsRepository,
    required this.charactersRepository,
  }) : super(DatabaseEditorInitial());
  final SpellsRepository spellsRepository;
  final FeatsRepository featsRepository;
  final ClassesRepository classesRepository;
  final RacesRepository racesRepository;
  final ItemsRepository itemsRepository;
  final CharactersRepository charactersRepository;

  Future<void> fetch(String slug, String type, {bool offline = false}) async {
    emit(DatabaseEditorLoading());
    try {
      final Map<String, dynamic> entry;
      switch (type) {
        case 'spells':
          entry = await spellsRepository.get(slug) as Map<String, dynamic>;
        case 'feats':
          entry = await featsRepository.get(slug) as Map<String, dynamic>;
        case 'classes':
          entry = await classesRepository.get(slug) as Map<String, dynamic>;
        case 'races':
          entry = await racesRepository.get(slug) as Map<String, dynamic>;
        case 'items':
          entry = await itemsRepository.get(slug) as Map<String, dynamic>;
        case 'characters':
          entry = await charactersRepository.get(slug, offline)
              as Map<String, dynamic>;
        default:
          emit(DatabaseEditorError());
          return;
      }
      emit(DatabaseEditorLoaded(entry: entry, slug: slug));
    } catch (e) {
      emit(DatabaseEditorError());
    }
  }

  Future<void> sync(
    Map<String, dynamic> entry,
    String type,
    String slug,
  ) async {
    switch (type) {
      case 'spells':
        await spellsRepository.sync(slug, entry);
      case 'feats':
        await featsRepository.sync(slug, entry);
      case 'classes':
        await classesRepository.sync(slug, entry);
      case 'races':
        await racesRepository.sync(slug, entry);
      case 'items':
        await itemsRepository.sync(slug, entry);
      case 'characters':
        return;
      default:
        return;
    }
    return;
  }

  Future<void> save(
    String slug,
    Map<String, dynamic> entry,
    String type,
  ) async {
    emit(DatabaseEditorLoading());
    try {
      switch (type) {
        case 'spells':
          await spellsRepository.save(slug, entry, false);
        case 'feats':
          await featsRepository.save(slug, entry, false);
        case 'classes':
          await classesRepository.save(slug, entry, false);
        case 'races':
          await racesRepository.save(slug, entry, false);
        case 'items':
          await itemsRepository.save(slug, entry, false);
        case 'characters':
          await charactersRepository.updateCharacter(slug, entry, false);
        default:
          emit(DatabaseEditorError());
          return;
      }
      emit(DatabaseEditorLoaded(entry: entry, slug: slug));
    } catch (e) {
      emit(DatabaseEditorError());
    }
  }
}
