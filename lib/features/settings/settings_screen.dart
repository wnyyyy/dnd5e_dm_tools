import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_event.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool? _isCasterDraft;

  @override
  void didChangeDependencies() {
    final state = context.read<SettingsCubit>().state;
    _isCasterDraft = state.isCaster;
    _nameController.text = state.name;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: _buildNameField(context, state),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.2,
                    ),
                    child: _buildIsCasterToggle(context, state),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: _buildEditButton(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNameField(BuildContext context, SettingsState state) {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(labelText: 'Name'),
      readOnly: !state.isEditMode,
    );
  }

  Widget _buildIsCasterToggle(BuildContext context, SettingsState state) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Is Caster'),
          value: _isCasterDraft ?? state.isCaster,
          onChanged: state.isEditMode
              ? (value) {
                  setState(() {
                    _isCasterDraft = value;
                  });
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context, SettingsState state) {
    if (state.isEditMode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<SettingsCubit>(
                context,
              ).changeName(name: _nameController.text);
              if (_isCasterDraft != null && _isCasterDraft != state.isCaster) {
                BlocProvider.of<SettingsCubit>(
                  context,
                ).setIsCaster(_isCasterDraft!);
              }
              BlocProvider.of<CharacterBloc>(
                context,
              ).add(CharacterLoad(_nameController.text));
              BlocProvider.of<SettingsCubit>(context).toggleEditMode();
              BlocProvider.of<CharacterBloc>(
                context,
              ).add(const PersistCharacter());
            },
            child: const Text('Save'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isCasterDraft = state.isCaster;
              });
              BlocProvider.of<SettingsCubit>(context).toggleEditMode();
              BlocProvider.of<CharacterBloc>(
                context,
              ).add(CharacterLoad(state.name));
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
  }
}
