import 'package:dnd5e_dm_tools/features/settings/bloc/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
      : super(SettingsState(
          name: '',
        ));

  void changeName(String name) {
    emit(state.copyWith(name: name));
  }
}
