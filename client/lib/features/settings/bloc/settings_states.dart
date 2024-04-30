class SettingsState {
  final String name;
  final bool isEditMode;

  SettingsState({required this.name, required this.isEditMode});

  SettingsState copyWith({
    String? name,
    bool? isEditMode,
  }) {
    return SettingsState(
      name: name ?? this.name,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }
}
