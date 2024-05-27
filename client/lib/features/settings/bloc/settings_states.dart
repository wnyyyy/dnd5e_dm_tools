import 'package:dnd5e_dm_tools/core/util/enum.dart';

abstract class SettingsState {
  var name = '';
  var isEditMode = false;
  var isCaster = false;
  var classOnlySpells = false;
  var isDarkMode = false;
  var themeColor = ThemeColor.chestnutBrown;
  var offlineMode = false;
  var isOnboardingComplete = false;

  SettingsState();
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsError extends SettingsState {
  final String message;

  SettingsError(this.message);
}

class SettingsLoaded extends SettingsState {
  SettingsLoaded({
    required String name,
    required bool isEditMode,
    required bool isCaster,
    required bool classOnlySpells,
    required bool isDarkMode,
    required ThemeColor themeColor,
    required bool offlineMode,
    required bool isOnboardingComplete,
  }) {
    this.name = name;
    this.isEditMode = isEditMode;
    this.isCaster = isCaster;
    this.classOnlySpells = classOnlySpells;
    this.isDarkMode = isDarkMode;
    this.themeColor = themeColor;
    this.offlineMode = offlineMode;
    this.isOnboardingComplete = isOnboardingComplete;
  }

  SettingsLoaded copyWith({
    String? name,
    bool? isEditMode,
    bool? isCaster,
    bool? classOnlySpells,
    bool? isDarkMode,
    ThemeColor? themeColor,
    bool? offlineMode,
  }) {
    return SettingsLoaded(
      name: name ?? this.name,
      isEditMode: isEditMode ?? this.isEditMode,
      isCaster: isCaster ?? this.isCaster,
      classOnlySpells: classOnlySpells ?? this.classOnlySpells,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      themeColor: themeColor ?? this.themeColor,
      offlineMode: offlineMode ?? this.offlineMode,
      isOnboardingComplete:
          name?.trim().isNotEmpty ?? this.name.trim().isNotEmpty,
    );
  }
}
