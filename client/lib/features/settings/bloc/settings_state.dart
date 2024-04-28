import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsStateInitial extends SettingsState {
  @override
  List<Object> get props => [];
}

class SettingsStateLoading extends SettingsState {
  @override
  List<Object> get props => [];
}

class SettingsStateError extends SettingsState {
  final Error error;
  const SettingsStateError(this.error);

  @override
  List<Object> get props => [error];
}

class SettingsStateLoaded extends SettingsState {
  final List<Character> characters;
  const SettingsStateLoaded(this.characters);

  @override
  List<Object> get props => [characters];
}
