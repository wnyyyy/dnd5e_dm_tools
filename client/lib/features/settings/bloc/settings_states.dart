class SettingsState {
  final String name;
  final bool isEditMode;
  final bool isCaster;
  final bool classOnlySpells;

  SettingsState({
    required this.name,
    required this.isEditMode,
    required this.isCaster,
    this.classOnlySpells = true,
  });

  SettingsState copyWith({
    String? name,
    bool? isEditMode,
    bool? isCaster,
    bool? classOnlySpells,
  }) {
    return SettingsState(
      name: name ?? this.name,
      isEditMode: isEditMode ?? this.isEditMode,
      isCaster: isCaster ?? this.isCaster,
      classOnlySpells: classOnlySpells ?? this.classOnlySpells,
    );
  }
}
