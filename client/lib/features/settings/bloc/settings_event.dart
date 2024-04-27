import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class SettingsLoad extends SettingsEvent {
  const SettingsLoad();

  @override
  List<Object> get props => [];
}

class TabUpdated extends SettingsEvent {
  final int index;

  const TabUpdated(this.index);

  @override
  List<Object> get props => [index];
}
