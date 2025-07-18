import 'package:dnd5e_dm_tools/core/util/enum.dart';

abstract class SettingsState {
  SettingsState();
  String name = '';
  bool isEditMode = false;
  bool isCaster = false;
  bool classOnlySpells = false;
  bool isDarkMode = false;
  ThemeColor themeColor = ThemeColor.chestnutBrown;
  bool cachedOnlyMode = false;
  bool isOnboardingComplete = false;
  ActionMenuMode selectedActionFilter = ActionMenuMode.all;
  EquipFilter selectedEquipFilter = EquipFilter.all;
  EquipSort selectedEquipSort = EquipSort.name;
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsError extends SettingsState {
  SettingsError(this.message);
  final String message;
}

class SettingsLoaded extends SettingsState {
  SettingsLoaded({
    required String name,
    required bool isEditMode,
    required bool isCaster,
    required bool classOnlySpells,
    required bool isDarkMode,
    required ThemeColor themeColor,
    required bool cachedOnlyMode,
    required bool isOnboardingComplete,
    required ActionMenuMode selectedActionFilter,
    required EquipFilter selectedEquipFilter,
    required EquipSort selectedEquipSort,
  }) {
    this.name = name;
    this.isEditMode = isEditMode;
    this.isCaster = isCaster;
    this.classOnlySpells = classOnlySpells;
    this.isDarkMode = isDarkMode;
    this.themeColor = themeColor;
    this.cachedOnlyMode = cachedOnlyMode;
    this.isOnboardingComplete = isOnboardingComplete;
    this.selectedActionFilter = selectedActionFilter;
    this.selectedEquipFilter = selectedEquipFilter;
    this.selectedEquipSort = selectedEquipSort;
  }

  SettingsLoaded copyWith({
    String? name,
    bool? isEditMode,
    bool? isCaster,
    bool? classOnlySpells,
    bool? isDarkMode,
    ThemeColor? themeColor,
    bool? cachedOnlyMode,
    bool? isOnboardingComplete,
    ActionMenuMode? selectedActionFilter,
    EquipFilter? selectedEquipFilter,
    EquipSort? selectedEquipSort,
  }) {
    return SettingsLoaded(
      name: name ?? this.name,
      isEditMode: isEditMode ?? this.isEditMode,
      isCaster: isCaster ?? this.isCaster,
      classOnlySpells: classOnlySpells ?? this.classOnlySpells,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      themeColor: themeColor ?? this.themeColor,
      cachedOnlyMode: cachedOnlyMode ?? this.cachedOnlyMode,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      selectedActionFilter: selectedActionFilter ?? this.selectedActionFilter,
      selectedEquipFilter: selectedEquipFilter ?? this.selectedEquipFilter,
      selectedEquipSort: selectedEquipSort ?? this.selectedEquipSort,
    );
  }
}
