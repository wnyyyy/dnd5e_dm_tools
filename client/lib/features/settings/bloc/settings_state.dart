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
  final String error;
  const SettingsStateError(this.error);

  @override
  List<Object> get props => [error];
}
