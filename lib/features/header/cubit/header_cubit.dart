import 'package:dnd5e_dm_tools/core/enum.dart';
import 'package:dnd5e_dm_tools/features/header/cubit/header_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HeaderCubit extends Cubit<HeaderState> {
  HeaderCubit()
      : super(HeaderState(
            connectionStatus: ConnectionStatus.notConnected,
            isDarkMode: false,
            pageTitle: ''));

  void updateConnectionStatus(ConnectionStatus status) {
    emit(state.copyWith(connectionStatus: status));
  }

  void toggleDarkMode() {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
  }

  void setPageTitle(String title) {
    emit(state.copyWith(pageTitle: title));
  }
}
