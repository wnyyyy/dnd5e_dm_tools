import 'package:dnd5e_dm_tools/features/main_screen/cubit/main_screen_states.dart';
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

  void showCampaign() {
    emit(MainScreenStateCampaign());
  }
}
