import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/hitdice.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/hp.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/spellbook.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/status_tab/widgets/stats.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/octicons_icons.dart';

class StatusTab extends StatelessWidget {
  final Map<String, dynamic> character;
  final String slug;
  final List<Map<String, dynamic>> table;

  const StatusTab({
    super.key,
    required this.character,
    required this.slug,
    required this.table,
  });

  @override
  Widget build(BuildContext context) {
    final isCaster = context.read<SettingsCubit>().state.isCaster;
    final Map<String, dynamic> spells;
    if (isCaster) {
      final classOnly = context.read<SettingsCubit>().state.classOnlySpells;
      if (classOnly) {
        spells =
            context.read<RulesCubit>().getSpellsByClass(character['class']);
      } else {
        spells = context.read<RulesCubit>().getAllSpells();
      }
    } else {
      spells = {};
    }
    final classs = context.read<RulesCubit>().getClass(character['class']);
    if (classs == null) {
      return Container();
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
                  slug: slug,
                ),
                HitDice(
                  character: character,
                  classs: classs,
                  slug: slug,
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
                                    spells: spells,
                                    slug: slug,
                                    table: table,
                                    updateCharacter: () =>
                                        context.read<CharacterBloc>().add(
                                              CharacterUpdate(
                                                character: character,
                                                slug: slug,
                                                offline: context
                                                    .read<SettingsCubit>()
                                                    .state
                                                    .offlineMode,
                                              ),
                                            ),
                                    onDone: () {
                                      context
                                          .read<CharacterBloc>()
                                          .add(PersistCharacter(
                                            offline: context
                                                .read<SettingsCubit>()
                                                .state
                                                .offlineMode,
                                          ));
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
                              slug: slug,
                              offline: context
                                  .read<SettingsCubit>()
                                  .state
                                  .offlineMode,
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
