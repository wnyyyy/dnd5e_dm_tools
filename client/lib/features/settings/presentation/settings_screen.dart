import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_event.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(children: [
        _buildNameField(context),
      ]),
    );
  }

  Widget _buildNameField(BuildContext context) {
    final String characterName =
        BlocProvider.of<SettingsCubit>(context).state.name;
    return TextFormField(
      initialValue: characterName,
      decoration: InputDecoration(
        labelText: 'Name',
      ),
      onFieldSubmitted: (value) {
        BlocProvider.of<SettingsCubit>(context).changeName(value);
        BlocProvider.of<CharacterBloc>(context).add(CharacterLoad(value));
      },
    );
  }
}
