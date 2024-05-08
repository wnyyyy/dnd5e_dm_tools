import 'package:dnd5e_dm_tools/core/data/repositories/classes_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/conditions_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/feats_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/races_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/spells_repository.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SpellsRepository spellsRepository;
  final FeatsRepository featsRepository;
  final ClassesRepository classesRepository;
  final ConditionsRepository conditionsRepository;
  final RacesRepository racesRepository;

  SettingsCubit({
    required this.spellsRepository,
    required this.featsRepository,
    required this.classesRepository,
    required this.conditionsRepository,
    required this.racesRepository,
  }) : super(SettingsInitial());

  void changeName(String name) async {
    if (name.isEmpty) return;
    if (state is! SettingsLoaded) return;
    await saveConfig('char_name', name);
    emit((state as SettingsLoaded).copyWith(name: name));
  }

  void toggleEditMode() async {
    if (state is! SettingsLoaded) return;
    emit((state as SettingsLoaded).copyWith(isEditMode: !state.isEditMode));
  }

  void toggleIsCaster() async {
    if (state is! SettingsLoaded) return;
    final isCaster = !state.isCaster;
    await saveConfig('is_caster', isCaster.toString());
    emit((state as SettingsLoaded).copyWith(isCaster: isCaster));
  }

  void toggleClassOnlySpells() async {
    if (state is! SettingsLoaded) return;
    final classOnly = !state.classOnlySpells;
    await saveConfig('class_only_spells', classOnly.toString());
    emit((state as SettingsLoaded).copyWith(classOnlySpells: classOnly));
  }

  void init() async {
    emit(SettingsLoading());
    try {
      final name = await readConfig('char_name') ?? '';
      final isCaster = await readConfig('is_caster') ?? 'false';
      final classOnly = await readConfig('class_only_spells') ?? 'false';
      await spellsRepository.init();
      await featsRepository.init();
      await classesRepository.init();
      await conditionsRepository.init();
      await racesRepository.init();
      print('Settings loaded');
      emit(SettingsLoaded(
        name: name,
        isCaster: isCaster == 'true',
        classOnlySpells: classOnly == 'true',
        isEditMode: false,
      ));
    } catch (error) {
      emit(SettingsError('Failed to load settings'));
    }
  }
}
