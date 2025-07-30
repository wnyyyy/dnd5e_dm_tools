import 'package:dnd5e_dm_tools/core/data/repositories/characters_repository.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required this.charactersRepository})
    : super(SettingsInitial());
  final CharactersRepository charactersRepository;

  Future<void> changeName({required String name, bool? caster}) async {
    if (name.isEmpty) return;
    if (state is! SettingsLoaded) return;
    await saveConfig('char_name', name);
    if (caster != null) {
      await saveConfig('is_caster', caster.toString());
      emit(
        (state as SettingsLoaded).copyWith(
          name: name,
          isCaster: caster,
          isOnboardingComplete: true,
        ),
      );
      return;
    }
    emit((state as SettingsLoaded).copyWith(name: name));
  }

  Future<void> changeTheme(ThemeColor themeColor, bool isDarkMode) async {
    await saveConfig('theme_color', themeColor.name);
    await saveConfig('is_dark_mode', isDarkMode.toString());
    emit(
      (state as SettingsLoaded).copyWith(
        themeColor: themeColor,
        isDarkMode: isDarkMode,
      ),
    );
  }

  Future<void> toggleEditMode() async {
    if (state is! SettingsLoaded) return;
    emit((state as SettingsLoaded).copyWith(isEditMode: !state.isEditMode));
  }

  Future<void> setIsCaster(bool isCaster) async {
    if (state is! SettingsLoaded) return;
    await saveConfig('is_caster', isCaster.toString());
    emit((state as SettingsLoaded).copyWith(isCaster: isCaster));
  }

  Future<void> toggleClassOnlySpells() async {
    if (state is! SettingsLoaded) return;
    final classOnly = !state.classOnlySpells;
    await saveConfig('class_only_spells', classOnly.toString());
    emit((state as SettingsLoaded).copyWith(classOnlySpells: classOnly));
  }

  Future<void> toggleActionFilter(ActionMenuMode selected) async {
    if (state is! SettingsLoaded) return;
    await saveConfig('selected_action_filter', selected.name);
    emit((state as SettingsLoaded).copyWith(selectedActionFilter: selected));
  }

  Future<void> toggleEquipFilter(EquipFilter selected) async {
    if (state is! SettingsLoaded) return;
    await saveConfig('selected_equip_filter', selected.name);
    emit((state as SettingsLoaded).copyWith(selectedEquipFilter: selected));
  }

  Future<void> toggleEquipSort(EquipSort selected) async {
    if (state is! SettingsLoaded) return;
    await saveConfig('selected_equip_sort', selected.name);
    emit((state as SettingsLoaded).copyWith(selectedEquipSort: selected));
  }

  Future<void> setCompactMode(bool compact) async {
    if (state is! SettingsLoaded) return;
    await saveConfig('actions_compact_mode', compact.toString());
    emit((state as SettingsLoaded).copyWith(actionsCompactMode: compact));
  }

  Future<void> init() async {
    emit(SettingsLoading());
    try {
      final name = await readConfig('char_name') ?? '';
      final isCaster = await readConfig('is_caster') ?? 'false';
      final classOnly = await readConfig('class_only_spells') ?? 'false';
      final themeColorName =
          await readConfig('theme_color') ?? ThemeColor.chestnutBrown.name;
      final isDarkMode = await readConfig('is_dark_mode') ?? 'false';
      final themeColor = ThemeColor.values.firstWhere(
        (e) => e.name == themeColorName,
        orElse: () => ThemeColor.chestnutBrown,
      );
      final isOnboardingComplete = name.trim().isNotEmpty;
      final selectedActionFilterName =
          await readConfig('selected_action_filter') ?? ActionMenuMode.all.name;
      final selectedActionFilter = ActionMenuMode.values.firstWhere(
        (e) => e.name == selectedActionFilterName,
        orElse: () => ActionMenuMode.all,
      );
      final selectedEquipFilterName =
          await readConfig('selected_equip_filter') ?? EquipFilter.all.name;
      final selectedEquipFilter = EquipFilter.values.firstWhere(
        (e) => e.name == selectedEquipFilterName,
        orElse: () => EquipFilter.all,
      );
      final selectedEquipSortName =
          await readConfig('selected_equip_sort') ?? EquipSort.type.name;
      final selectedEquipSort = EquipSort.values.firstWhere(
        (e) => e.name == selectedEquipSortName,
        orElse: () => EquipSort.type,
      );
      final actionsCompactMode =
          await readConfig('actions_compact_mode') ?? 'false';

      logBloc('Settings loaded', level: Level.info);

      emit(
        SettingsLoaded(
          name: name,
          isCaster: isCaster == 'true',
          classOnlySpells: classOnly == 'true',
          isEditMode: false,
          themeColor: themeColor,
          isDarkMode: isDarkMode == 'true',
          isOnboardingComplete: isOnboardingComplete,
          selectedActionFilter: selectedActionFilter,
          selectedEquipFilter: selectedEquipFilter,
          selectedEquipSort: selectedEquipSort,
          actionsCompactMode: actionsCompactMode == 'true',
        ),
      );
    } catch (error) {
      logBloc('Error loading settings: $error', level: Level.error);
      emit(SettingsError('Failed to load settings'));
    }
  }
}
