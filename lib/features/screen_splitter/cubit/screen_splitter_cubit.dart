import 'package:dnd5e_dm_tools/features/screen_splitter/cubit/screen_splitter_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenSplitterCubit extends Cubit<ScreenSplitterState> {
  ScreenSplitterCubit() : super(ScreenSplitterStateLowerExpanded());

  void expandUpperScreen() {
    emit(ScreenSplitterStateUpperExpanded());
  }

  void expandLowerScreen() {
    emit(ScreenSplitterStateLowerExpanded());
  }

  void equalizeScreen() {
    emit(ScreenSplitterStateEqual());
  }
}
