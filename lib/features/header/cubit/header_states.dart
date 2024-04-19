import 'package:dnd5e_dm_tools/core/enum.dart';

class HeaderState {
  final ConnectionStatus connectionStatus;
  final bool isDarkMode;
  final String pageTitle;

  HeaderState(
      {required this.connectionStatus,
      required this.isDarkMode,
      required this.pageTitle});

  HeaderState copyWith({
    ConnectionStatus? connectionStatus,
    bool? isDarkMode,
    String? pageTitle,
  }) {
    return HeaderState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      pageTitle: pageTitle ?? this.pageTitle,
    );
  }
}
