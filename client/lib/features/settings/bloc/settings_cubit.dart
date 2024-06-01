import 'package:dnd5e_dm_tools/core/data/repositories/characters_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/classes_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/conditions_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/feats_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/items_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/races_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/spells_repository.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsCubit extends Cubit<SettingsState> {

  SettingsCubit({
    required this.spellsRepository,
    required this.featsRepository,
    required this.classesRepository,
    required this.conditionsRepository,
    required this.racesRepository,
    required this.itemsRepository,
    required this.charactersRepository,
  }) : super(SettingsInitial());
  final SpellsRepository spellsRepository;
  final FeatsRepository featsRepository;
  final ClassesRepository classesRepository;
  final ConditionsRepository conditionsRepository;
  final RacesRepository racesRepository;
  final ItemsRepository itemsRepository;
  final CharactersRepository charactersRepository;

  Future<void> changeName({required String name, bool? caster}) async {
    if (name.isEmpty) return;
    if (state is! SettingsLoaded) return;
    await saveConfig('char_name', name);
    if (caster != null) {
      await saveConfig('is_caster', caster.toString());
      emit((state as SettingsLoaded).copyWith(name: name, isCaster: caster));
      return;
    }
    emit((state as SettingsLoaded).copyWith(name: name));
  }

  Future<void> changeTheme(ThemeColor themeColor, bool isDarkMode) async {
    await saveConfig('theme_color', themeColor.name);
    await saveConfig('is_dark_mode', isDarkMode.toString());
    emit((state as SettingsLoaded)
        .copyWith(themeColor: themeColor, isDarkMode: isDarkMode),);
  }

  Future<void> toggleEditMode() async {
    if (state is! SettingsLoaded) return;
    emit((state as SettingsLoaded).copyWith(isEditMode: !state.isEditMode));
  }

  Future<void> toggleIsCaster() async {
    if (state is! SettingsLoaded) return;
    final isCaster = !state.isCaster;
    await saveConfig('is_caster', isCaster.toString());
    emit((state as SettingsLoaded).copyWith(isCaster: isCaster));
  }

  Future<void> toggleClassOnlySpells() async {
    if (state is! SettingsLoaded) return;
    final classOnly = !state.classOnlySpells;
    await saveConfig('class_only_spells', classOnly.toString());
    emit((state as SettingsLoaded).copyWith(classOnlySpells: classOnly));
  }

  Future<void> toggleOfflineMode() async {
    if (state is! SettingsLoaded) return;
    final offlineMode = !state.offlineMode;
    await saveConfig('offline_mode', offlineMode.toString());
    emit((state as SettingsLoaded).copyWith(offlineMode: offlineMode));
  }

  Future<void> init() async {
    emit(SettingsLoading());
    try {
      final name = await readConfig('char_name') ?? '';
      final isCaster = await readConfig('is_caster') ?? 'false';
      final classOnly = await readConfig('class_only_spells') ?? 'false';
      final offlineMode = await readConfig('offline_mode') ?? 'false';
      final themeColorName =
          await readConfig('theme_color') ?? ThemeColor.chestnutBrown.name;
      final isDarkMode = await readConfig('is_dark_mode') ?? 'false';
      final themeColor = ThemeColor.values.firstWhere(
          (e) => e.name == themeColorName,
          orElse: () => ThemeColor.chestnutBrown,);
      final isOnboardingComplete = name.trim().isNotEmpty;

      await spellsRepository.init();
      await featsRepository.init();
      await classesRepository.init();
      await conditionsRepository.init();
      await racesRepository.init();
      await itemsRepository.init();
      await charactersRepository.init();
      print('Settings loaded');

      emit(SettingsLoaded(
        name: name,
        isCaster: isCaster == 'true',
        classOnlySpells: classOnly == 'true',
        isEditMode: false,
        themeColor: themeColor,
        isDarkMode: isDarkMode == 'true',
        offlineMode: offlineMode == 'true',
        isOnboardingComplete: isOnboardingComplete,
      ),);
    } catch (error) {
      emit(SettingsError('Failed to load settings'));
    }
  }
}
