class SettingsState {
  final String name;
  final bool isEditMode;
  final bool isCaster;

  SettingsState(
      {required this.name, required this.isEditMode, required this.isCaster});

  SettingsState copyWith({
    String? name,
    bool? isEditMode,
    bool? isCaster,
  }) {
    return SettingsState(
      name: name ?? this.name,
      isEditMode: isEditMode ?? this.isEditMode,
      isCaster: isCaster ?? this.isCaster,
    );
  }
}
