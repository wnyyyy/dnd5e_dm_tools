import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
import 'package:dnd5e_dm_tools/core/data/models/item.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';
import 'package:dnd5e_dm_tools/core/data/models/spell.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/classes_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/feats_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/items_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/races_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/spells_repository.dart';
import 'package:dnd5e_dm_tools/features/database_editor/bloc/database_editor_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DatabaseEditorCubit extends Cubit<DatabaseEditorState> {
  DatabaseEditorCubit({
    required this.spellsRepository,
    required this.featsRepository,
    required this.classesRepository,
    required this.racesRepository,
    required this.itemsRepository,
  }) : super(
         const DatabaseEditorInitial(selectedIndex: 0, selectedUpdate: false),
       );
  final SpellsRepository spellsRepository;
  final FeatsRepository featsRepository;
  final ClassesRepository classesRepository;
  final RacesRepository racesRepository;
  final ItemsRepository itemsRepository;

  void setSelectedIndex(int index) {
    emit(DatabaseEditorInitial(selectedIndex: index, selectedUpdate: false));
  }

  void setSelectedUpdate(bool update) {
    emit(
      DatabaseEditorInitial(
        selectedIndex: state.selectedIndex,
        selectedUpdate: update,
      ),
    );
  }

  Future<void> fetch(String slug, String type) async {
    if (state.selectedUpdate) {
      return;
    }
    emit(
      DatabaseEditorLoading(
        selectedIndex: state.selectedIndex,
        selectedUpdate: false,
      ),
    );
    try {
      final Map<String, dynamic> entry;
      switch (type) {
        case 'spells':
          entry = await spellsRepository.getData(slug, online: true);
        case 'feats':
          entry = await featsRepository.getData(slug, online: true);
        case 'classes':
          entry = await classesRepository.getData(slug, online: true);
        case 'races':
          entry = await racesRepository.getData(slug, online: true);
        case 'items':
          entry = await itemsRepository.getData(slug, online: true);
        default:
          emit(
            DatabaseEditorError(
              selectedIndex: state.selectedIndex,
              selectedUpdate: false,
            ),
          );
          return;
      }
      entry['slug'] = slug;
      emit(
        DatabaseEditorLoaded(
          entry: entry,
          originalEntry: Map<String, dynamic>.from(entry),
          slug: slug,
          selectedIndex: state.selectedIndex,
          selectedUpdate: false,
        ),
      );
    } catch (e) {
      emit(
        DatabaseEditorError(
          selectedIndex: state.selectedIndex,
          selectedUpdate: false,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> sync(String type, String slug) async {
    if (state is! DatabaseEditorLoaded) {
      return;
    }
    final prevState = (state as DatabaseEditorLoaded).copyWith();
    emit(
      DatabaseEditorLoading(
        selectedIndex: state.selectedIndex,
        selectedUpdate: false,
      ),
    );
    final Map<String, dynamic> entry;
    switch (type) {
      case 'spells':
        await spellsRepository.sync(slug);
        entry = await spellsRepository.getData(slug);
      case 'feats':
        await featsRepository.sync(slug);
        entry = await featsRepository.getData(slug);
      case 'classes':
        await classesRepository.sync(slug);
        entry = await classesRepository.getData(slug);
      case 'races':
        await racesRepository.sync(slug);
        entry = await racesRepository.getData(slug);
      case 'items':
        await itemsRepository.sync(slug);
        entry = await itemsRepository.getData(slug);
      case 'characters':
        emit(
          DatabaseEditorError(
            selectedIndex: state.selectedIndex,
            selectedUpdate: false,
            message: 'Character syncing is not supported',
          ),
        );
        return;
      default:
        emit(
          DatabaseEditorError(
            selectedIndex: state.selectedIndex,
            selectedUpdate: false,
            message: 'Unknown type: $type',
          ),
        );
        return;
    }
    entry['slug'] = slug;
    emit(
      DatabaseEditorSynced(
        type: type,
        previousState: prevState,
        selectedIndex: state.selectedIndex,
        selectedUpdate: false,
      ),
    );
  }

  Future<void> save(
    String slug,
    Map<String, dynamic> editedEntry,
    String type,
  ) async {
    if (state is! DatabaseEditorLoaded) {
      return;
    }
    final originalEntry = (state as DatabaseEditorLoaded).originalEntry;
    emit(
      DatabaseEditorLoading(
        selectedIndex: state.selectedIndex,
        selectedUpdate: false,
      ),
    );
    try {
      switch (type) {
        case 'spells':
          await spellsRepository.save(
            slug,
            Spell.fromJson(editedEntry, slug),
            false,
          );
        case 'feats':
          await featsRepository.save(
            slug,
            Feat.fromJson(editedEntry, slug),
            false,
          );
        case 'classes':
          editedEntry['table'] = originalEntry['table'] ?? editedEntry['table'];
          editedEntry['archetypes'] =
              originalEntry['archetypes'] ?? editedEntry['archetypes'];
          await classesRepository.save(
            slug,
            Class.fromJson(editedEntry, slug),
            false,
          );
        case 'races':
          editedEntry['traits'] =
              originalEntry['traits'] ?? editedEntry['traits'];
          editedEntry['asi'] = originalEntry['asi'] ?? editedEntry['asi'];
          editedEntry['speed'] = originalEntry['speed'] ?? editedEntry['speed'];
          await racesRepository.save(
            slug,
            Race.fromJson(editedEntry, slug),
            false,
          );
        case 'items':
          await itemsRepository.save(slug, Item.fromJson(editedEntry), false);
        default:
          emit(
            DatabaseEditorError(
              selectedIndex: state.selectedIndex,
              selectedUpdate: false,
            ),
          );
          return;
      }
      emit(
        DatabaseEditorLoaded(
          entry: editedEntry,
          originalEntry: originalEntry,
          slug: slug,
          selectedIndex: state.selectedIndex,
          selectedUpdate: false,
        ),
      );
    } catch (e) {
      emit(
        DatabaseEditorError(
          selectedIndex: state.selectedIndex,
          selectedUpdate: false,
          message: e.toString(),
        ),
      );
    }
  }
}
