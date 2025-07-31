import 'package:dnd5e_dm_tools/features/main_screen/bloc/main_screen_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreenCubit extends Cubit<MainScreenState> {
  MainScreenCubit() : super(MainScreenStateCharacter());

  void showCharacter() {
    emit(MainScreenStateCharacter());
  }

  void showSettings() {
    emit(MainScreenStateSettings());
  }

  void showDatabase() {
    emit(MainScreenStateDatabase());
  }
}
