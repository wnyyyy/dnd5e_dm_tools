import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: _buildNameField(context),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2),
                child: _buildIsCasterToggle(context),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: _buildEditButton(context),
          ),
        ]);
  }

  Widget _buildNameField(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return TextFormField(
          initialValue: state.name,
          decoration: const InputDecoration(labelText: 'Name'),
          readOnly: !state.isEditMode,
          onFieldSubmitted: (value) {
            if (state.isEditMode) {
              BlocProvider.of<SettingsCubit>(context).changeName(value);
              BlocProvider.of<CharacterBloc>(context).add(CharacterLoad(value));
            }
          },
        );
      },
    );
  }

  Widget _buildIsCasterToggle(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Column(
          children: [
            SwitchListTile(
              title: const Text('Is Caster'),
              value: state.isCaster,
              onChanged: (value) {
                BlocProvider.of<SettingsCubit>(context).toggleIsCaster();
              },
            ),
            Visibility(
                visible: state.isCaster,
                child: SwitchListTile(
                  title: const Text('Class-only spells'),
                  value: state.classOnlySpells,
                  onChanged: (value) {
                    BlocProvider.of<SettingsCubit>(context)
                        .toggleClassOnlySpells();
                  },
                )),
          ],
        );
      },
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (state.isEditMode) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<SettingsCubit>(context).toggleEditMode();
                  BlocProvider.of<CharacterBloc>(context)
                      .add(const PersistCharacter());
                },
                child: const Text('Save'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<SettingsCubit>(context).toggleEditMode();
                  BlocProvider.of<CharacterBloc>(context)
                      .add(CharacterLoad(state.name));
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () =>
                    BlocProvider.of<SettingsCubit>(context).toggleEditMode(),
                child: const Text('Edit'),
              ),
            ],
          );
        }
      },
    );
  }
}
