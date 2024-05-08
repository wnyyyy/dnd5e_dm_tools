import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/hitdice.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/hp.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/spellbook.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/stats.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/octicons_icons.dart';

class StatusTab extends StatelessWidget {
  final Map<String, dynamic> character;
  final Map<String, dynamic> classs;
  final Map<String, dynamic>? spells;
  final String name;

  const StatusTab({
    super.key,
    required this.character,
    required this.name,
    required this.classs,
    required this.spells,
  });

  @override
  Widget build(BuildContext context) {
    final isCaster = context.read<SettingsCubit>().state.isCaster;
    if (isCaster) {
      if (spells?.isEmpty ?? true) {
        context.read<CharacterBloc>().add(const LoadSpells());
        return const Center(child: CircularProgressIndicator());
      }
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flex(
              direction: Axis.vertical,
              children: [
                Hitpoints(
                  character: character,
                  name: name,
                ),
                HitDice(
                  character: character,
                  classs: classs,
                  name: name,
                )
              ],
            ),
            Flex(
              direction: Axis.vertical,
              children: [
                if (isCaster)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: IconButton.outlined(
                      padding: const EdgeInsets.all(12),
                      iconSize: 36,
                      icon: const Icon(Octicons.book),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Spellbook'),
                                content: Spellbook(
                                    character: character,
                                    spells: spells ?? {},
                                    updateCharacter: () =>
                                        context.read<CharacterBloc>().add(
                                              CharacterUpdate(
                                                character: character,
                                                name: name,
                                              ),
                                            ),
                                    onDone: () {
                                      context
                                          .read<CharacterBloc>()
                                          .add(const PersistCharacter());
                                      Navigator.of(context).pop();
                                    }),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Icon(Icons.done),
                                  ),
                                ],
                              );
                            });
                      },
                    ),
                  ),
                StatsView(
                    onSave: () =>
                        context.read<CharacterBloc>().add(CharacterUpdate(
                              character: character,
                              name: name,
                            )),
                    character: character),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
