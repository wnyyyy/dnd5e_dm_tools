import 'package:dnd5e_dm_tools/features/characters/bloc/character_event.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterScreenBloc
    extends Bloc<CharacterScreenEvent, CharacterScreenState> {
  CharacterScreenBloc() : super(CharacterScreenStateInitial());
}
