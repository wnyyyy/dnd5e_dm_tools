class HeaderState {
  final bool isDarkMode;

  HeaderState({required this.isDarkMode});

  HeaderState copyWith({
    bool? isDarkMode,
  }) {
    return HeaderState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
