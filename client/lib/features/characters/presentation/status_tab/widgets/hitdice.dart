import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HitDice extends StatelessWidget {
  const HitDice({
    super.key,
    required this.character,
    required this.classs,
    required this.slug,
  });

  final Map<String, dynamic> character;
  final Map<String, dynamic> classs;
  final String slug;

  @override
  Widget build(BuildContext context) {
    final editMode = Provider.of<SettingsCubit>(context).state.isEditMode;
    final maxHd =
        character['hd_max'] as int? ?? character['level'] as int? ?? 1;
    final currentHd = character['hd_curr'] as int? ?? maxHd;
    final hd = classs['hit_dice'] as String? ?? '1d8';

    void editHd(String attributeName) {
      final TextEditingController maxHpController =
          TextEditingController(text: character['hd_max']?.toString() ?? '0');
      final TextEditingController currentHpController = TextEditingController(
        text: character['hd_curr']?.toString() ?? maxHpController.text,
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit $attributeName Hitpoints'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: maxHpController,
                  decoration: const InputDecoration(
                    labelText: 'Max Hitdice',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: currentHpController,
                  decoration: const InputDecoration(
                    labelText: 'Current Hitdice',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              TextButton(
                child: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Icon(Icons.check),
                onPressed: () {
                  character['hd_max'] = int.tryParse(maxHpController.text) ?? 0;
                  character['hd_curr'] =
                      int.tryParse(currentHpController.text) ??
                          int.tryParse(maxHpController.text) ??
                          0;
                  context.read<CharacterBloc>().add(
                        CharacterUpdate(
                          character: character,
                          slug: slug,
                          offline:
                              context.read<SettingsCubit>().state.offlineMode,
                          persistData: true,
                        ),
                      );

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void showRestDialog(int currHitDie, int maxHitDie) {
      bool isShort = true;
      int currHitDieInput = currHitDie;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Rest'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ChoiceChip(
                          label: const Text('Short'),
                          selected: isShort,
                          onSelected: (selected) {
                            if (!isShort) {
                              setState(() {
                                isShort = true;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 24),
                        ChoiceChip(
                          label: const Text('Long'),
                          selected: !isShort,
                          onSelected: (selected) {
                            if (isShort) {
                              setState(() {
                                isShort = false;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    if (isShort)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: IconButton(
                                    onPressed: () {
                                      if (currHitDieInput > 0) {
                                        setState(() {
                                          currHitDieInput--;
                                        });
                                      }
                                    },
                                    iconSize: 32,
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                  ),
                                ),
                                Text(
                                  '$currHitDieInput',
                                  style:
                                      Theme.of(context).textTheme.displaySmall,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 6.0),
                                  child: IconButton(
                                    iconSize: 32,
                                    onPressed: () {
                                      if (currHitDieInput < currHitDie) {
                                        setState(() {
                                          currHitDieInput++;
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions: [
                  TextButton(
                    child: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Icon(Icons.check),
                    onPressed: () {
                      Navigator.of(context).pop();
                      final characterActions = (character['actions']
                                  as Map<String, dynamic>?)
                              ?.values
                              .map(
                                (action) =>
                                    Map<String, dynamic>.from(action as Map),
                              )
                              .toList() ??
                          [];
                      if (isShort) {
                        if (currHitDieInput > 0) {
                          character['hd_curr'] = currHitDie - currHitDieInput;
                          if (character['class'] == 'warlock') {
                            character['expended_spell_slots'] = {};
                          }
                          for (final action in characterActions) {
                            if (action['requires_resource'] as bool? ?? false) {
                              if (action['resource_type']?.toString() ==
                                  'shortRest') {
                                action['used_count'] = 0;
                              }
                            }
                          }
                          context.read<CharacterBloc>().add(
                                CharacterUpdate(
                                  character: character,
                                  slug: slug,
                                  offline: context
                                      .read<SettingsCubit>()
                                      .state
                                      .offlineMode,
                                  persistData: true,
                                ),
                              );
                        }
                      } else {
                        character['hd_curr'] = maxHitDie;
                        character['expended_spell_slots'] = {};
                        for (final action in characterActions) {
                          if (action['requires_resource'] as bool? ?? false) {
                            if (action['resource_type']?.toString() ==
                                    'longRest' ||
                                action['resource_type']?.toString() ==
                                    'shortRest') {
                              action['used_count'] = 0;
                            }
                          }
                        }
                        context.read<CharacterBloc>().add(
                              CharacterUpdate(
                                character: character,
                                slug: slug,
                                offline: context
                                    .read<SettingsCubit>()
                                    .state
                                    .offlineMode,
                                persistData: true,
                              ),
                            );
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return GestureDetector(
      onLongPress: () => editHd('Hit Dice'),
      onTap: editMode ? () => editHd('Hit Dice') : null,
      child: Card(
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  'Hit Dice\n($hd)',
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      '$currentHd/$maxHd',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => showRestDialog(currentHd, maxHd),
                  child: const Text('Rest'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
