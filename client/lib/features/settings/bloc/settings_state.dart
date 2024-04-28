class SettingsState {
  final String name;

  SettingsState({required this.name});

  SettingsState copyWith({
    String? name,
  }) {
    return SettingsState(
      name: name ?? this.name,
    );
  }
}
