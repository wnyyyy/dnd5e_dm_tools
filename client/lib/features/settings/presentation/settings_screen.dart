import 'package:dnd5e_dm_tools/core/widgets/error_handler.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_bloc.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsStateLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (state is SettingsStateError) {
          return ErrorHandler(error: state.error);
        }
        if (state is SettingsStateLoaded) {
          Container();
        }
        return Container();
      },
    );
  }
}
