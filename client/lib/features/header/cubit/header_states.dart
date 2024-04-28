import 'package:dnd5e_dm_tools/core/util/enum.dart';

class HeaderState {
  final ConnectionStatus connectionStatus;
  final bool isDarkMode;

  HeaderState({required this.connectionStatus, required this.isDarkMode});

  HeaderState copyWith({
    ConnectionStatus? connectionStatus,
    bool? isDarkMode,
  }) {
    return HeaderState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
