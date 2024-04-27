import 'package:dnd5e_dm_tools/core/data/repositories/race_repository.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_event.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_state.dart';
import 'package:dnd5e_dm_tools/features/settings/data/settings_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;
  final RaceRepository raceRepository;
  final String SettingsName;

  SettingsBloc(this.settingsRepository, this.raceRepository, this.SettingsName)
      : super(SettingsStateInitial());
}
