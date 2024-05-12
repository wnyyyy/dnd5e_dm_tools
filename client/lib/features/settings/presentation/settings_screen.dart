import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) => previous.name != current.name,
      listener: (context, state) {
        _nameController.text = state.name;
      },
      buildWhen: (previous, current) => previous.name != current.name,
      builder: (context, state) {
        if (_nameController.text != state.name) {
          _nameController.text = state.name;
        }
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
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.2),
                  child: _buildIsCasterToggle(context),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.2),
              child: _buildIsOfflineModeToggle(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: _buildEditButton(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIsOfflineModeToggle(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Column(
          children: [
            SwitchListTile(
              title: const Text('Offline Mode'),
              value: state.offlineMode,
              onChanged: (value) {
                BlocProvider.of<SettingsCubit>(context).toggleOfflineMode();
              },
            ),
            if (state.offlineMode)
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<CharacterBloc>(context)
                      .add(const PersistCharacter(
                    offline: false,
                  ));
                },
                child: const Text('Persist'),
              ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildNameField(BuildContext context) {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(labelText: 'Name'),
      readOnly: !BlocProvider.of<SettingsCubit>(context).state.isEditMode,
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
                  BlocProvider.of<SettingsCubit>(context)
                      .changeName(_nameController.text);
                  BlocProvider.of<CharacterBloc>(context).add(CharacterLoad(
                    _nameController.text,
                    offline: context.read<SettingsCubit>().state.offlineMode,
                  ));
                  BlocProvider.of<SettingsCubit>(context).toggleEditMode();
                  BlocProvider.of<CharacterBloc>(context).add(PersistCharacter(
                    offline: context.read<SettingsCubit>().state.offlineMode,
                  ));
                },
                child: const Text('Save'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<SettingsCubit>(context).toggleEditMode();
                  BlocProvider.of<CharacterBloc>(context).add(CharacterLoad(
                    state.name,
                    offline: context.read<SettingsCubit>().state.offlineMode,
                  ));
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
