import 'package:dnd5e_dm_tools/core/data/repositories/spells_repository.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SpellsRepository spellsRepository;
  SettingsCubit({required this.spellsRepository})
      : super(SettingsState(
          name: '',
          isEditMode: false,
          isCaster: false,
        ));

  void changeName(String name) {
    emit(state.copyWith(name: name));
  }

  void toggleEditMode() {
    emit(state.copyWith(isEditMode: !state.isEditMode));
  }

  void toggleIsCaster() {
    emit(state.copyWith(isCaster: !state.isCaster));
  }

  void toggleClassOnlySpells() {
    spellsRepository.clearCache();
    emit(state.copyWith(classOnlySpells: !state.classOnlySpells));
  }
}
