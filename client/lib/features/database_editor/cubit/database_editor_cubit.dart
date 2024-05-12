import 'package:dnd5e_dm_tools/core/data/repositories/characters_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/classes_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/feats_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/items_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/races_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/spells_repository.dart';
import 'package:dnd5e_dm_tools/features/database_editor/cubit/database_editor_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DatabaseEditorCubit extends Cubit<DatabaseEditorState> {
  final SpellsRepository spellsRepository;
  final FeatsRepository featsRepository;
  final ClassesRepository classesRepository;
  final RacesRepository racesRepository;
  final ItemsRepository itemsRepository;
  final CharactersRepository charactersRepository;

  DatabaseEditorCubit({
    required this.spellsRepository,
    required this.featsRepository,
    required this.classesRepository,
    required this.racesRepository,
    required this.itemsRepository,
    required this.charactersRepository,
  }) : super(DatabaseEditorInitial());

  Future<void> fetch(String slug, String type, {bool offline = false}) async {
    emit(DatabaseEditorLoading());
    try {
      final Map<String, dynamic> entry;
      switch (type) {
        case 'spells':
          entry = await spellsRepository.get(slug);
          break;
        case 'feats':
          entry = await featsRepository.get(slug);
          break;
        case 'classes':
          entry = await classesRepository.get(slug);
          break;
        case 'races':
          entry = await racesRepository.get(slug);
          break;
        case 'items':
          entry = await itemsRepository.get(slug);
          break;
        case 'characters':
          entry = await charactersRepository.get(slug, offline);
          break;
        default:
          emit(DatabaseEditorError());
          return;
      }
      emit(DatabaseEditorLoaded(entry: entry));
    } catch (e) {
      emit(DatabaseEditorError());
    }
  }

  Future<void> save(
      String slug, Map<String, dynamic> entry, String type) async {
    emit(DatabaseEditorLoading());
    try {
      switch (type) {
        case 'spells':
          await spellsRepository.save(slug, entry, false);
          break;
        case 'feats':
          await featsRepository.save(slug, entry, false);
          break;
        case 'classes':
          await classesRepository.save(slug, entry, false);
          break;
        case 'races':
          await racesRepository.save(slug, entry, false);
          break;
        case 'items':
          await itemsRepository.save(slug, entry, false);
          break;
        case 'characters':
          await charactersRepository.updateCharacter(slug, entry, false);
          break;
        default:
          emit(DatabaseEditorError());
          return;
      }
      emit(DatabaseEditorLoaded(entry: entry));
    } catch (e) {
      emit(DatabaseEditorError());
    }
  }
}
