import 'package:dnd5e_dm_tools/features/header/cubit/header_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HeaderCubit extends Cubit<HeaderState> {
  HeaderCubit() : super(HeaderState(isDarkMode: false));

  void toggleDarkMode() {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
  }
}
