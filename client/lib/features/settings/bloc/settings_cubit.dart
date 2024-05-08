import 'package:dnd5e_dm_tools/core/data/repositories/spells_repository.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SpellsRepository spellsRepository;
  SettingsCubit({required this.spellsRepository}) : super(SettingsInitial()) {
    loadPersistent();
  }

  void changeName(String name) async {
    if (name.isEmpty) return;
    if (state is! SettingsLoaded) return;
    await saveConfig('char_name', name);
    emit(state.copyWith(name: name));
  }

  void toggleEditMode() async {
    emit(state.copyWith(isEditMode: !state.isEditMode));
  }

  void toggleIsCaster() async {
    final isCaster = !state.isCaster;
    await saveConfig('is_caster', isCaster.toString());
    emit(state.copyWith(isCaster: isCaster));
  }

  void toggleClassOnlySpells() async {
    final classOnly = !state.classOnlySpells;
    await saveConfig('class_only_spells', classOnly.toString());
    emit(state.copyWith(classOnlySpells: classOnly));
  }

  void loadPersistent() async {
    final name = await readConfig('char_name') ?? '';
    final isCaster = await readConfig('is_caster') ?? 'false';
    final classOnly = await readConfig('class_only_spells') ?? 'false';
    emit(state.copyWith(
      name: name,
      isCaster: isCaster == 'true',
      classOnlySpells: classOnly == 'true',
    ));
  }
}
