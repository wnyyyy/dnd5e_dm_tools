import 'package:dnd5e_dm_tools/core/config/app_colors.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab.dart/widgets/saving_throw.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavingThrowList extends StatefulWidget {
  const SavingThrowList({
    super.key,
    required this.character,
    required this.classs,
    required this.slug,
  });

  final Map<String, dynamic> character;
  final Map<String, dynamic> classs;
  final String slug;

  @override
  State<SavingThrowList> createState() => _SavingThrowListState();
}

class _SavingThrowListState extends State<SavingThrowList> {
  late List<String> charProf;

  @override
  void initState() {
    super.initState();
    final profStr = widget.character['prof_saving_throws'] ??
        widget.classs['prof_saving_throws'];
    charProf = profStr
        .toString()
        .toLowerCase()
        .split(',')
        .map((e) => e.trim())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final editMode = Provider.of<SettingsCubit>(context).state.isEditMode;
    final asi = getAsi(widget.character);
    final profBonus = getProfBonus(widget.character['level'] as int? ?? 1);

    void editSavingThrow(String attributeName) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final attr = attributeName.toLowerCase();
          bool isProficient = charProf.contains(attr);
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return AlertDialog(
                title: Text('Edit $attributeName Saving Throw'),
                content: CheckboxListTile(
                  title: const Text('Proficient'),
                  value: isProficient,
                  onChanged: (bool? value) {
                    if (value != null) {
                      setDialogState(() {
                        if (value) {
                          if (!charProf.contains(attr)) {
                            charProf.add(attr);
                          }
                        } else {
                          charProf.remove(attr);
                        }
                        isProficient = value;
                      });
                    }
                  },
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
                      widget.character['prof_saving_throws'] =
                          charProf.join(',');
                      context.read<CharacterBloc>().add(
                            CharacterUpdate(
                              character: widget.character,
                              slug: widget.slug,
                              offline: context
                                  .read<SettingsCubit>()
                                  .state
                                  .offlineMode,
                            ),
                          );
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return Card.outlined(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Saving Throws',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Flex(
              direction: Axis.vertical,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SavingThrow(
                          attributePrefix: 'STR',
                          attributeValue: asi['strength'] ?? 10,
                          color: Theme.of(context).strengthColor,
                          proficiency:
                              charProf.contains('strength') ? profBonus : null,
                          onTap: editMode
                              ? () => editSavingThrow('Strength')
                              : null,
                          onLongPress: () => editSavingThrow('Strength'),
                        ),
                        const SizedBox(height: 12),
                        SavingThrow(
                          attributePrefix: 'DEX',
                          attributeValue: asi['dexterity'] ?? 10,
                          color: Theme.of(context).dexterityColor,
                          proficiency:
                              charProf.contains('dexterity') ? profBonus : null,
                          onTap: editMode
                              ? () => editSavingThrow('Dexterity')
                              : null,
                          onLongPress: () => editSavingThrow('Dexterity'),
                        ),
                        const SizedBox(height: 12),
                        SavingThrow(
                          attributePrefix: 'CON',
                          attributeValue: asi['constitution'] ?? 10,
                          color: Theme.of(context).constitutionColor,
                          proficiency: charProf.contains('constitution')
                              ? profBonus
                              : null,
                          onTap: editMode
                              ? () => editSavingThrow('Constitution')
                              : null,
                          onLongPress: () => editSavingThrow('Constitution'),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        SavingThrow(
                          attributePrefix: 'INT',
                          attributeValue: asi['intelligence'] ?? 10,
                          color: Theme.of(context).intelligenceColor,
                          proficiency: charProf.contains('intelligence')
                              ? profBonus
                              : null,
                          onTap: editMode
                              ? () => editSavingThrow('Intelligence')
                              : null,
                          onLongPress: () => editSavingThrow('Intelligence'),
                        ),
                        const SizedBox(height: 12),
                        SavingThrow(
                          attributePrefix: 'WIS',
                          attributeValue: asi['wisdom'] ?? 10,
                          color: Theme.of(context).wisdomColor,
                          proficiency:
                              charProf.contains('wisdom') ? profBonus : null,
                          onTap:
                              editMode ? () => editSavingThrow('Wisdom') : null,
                          onLongPress: () => editSavingThrow('Wisdom'),
                        ),
                        const SizedBox(height: 12),
                        SavingThrow(
                          attributePrefix: 'CHA',
                          attributeValue: asi['charisma'] ?? 10,
                          color: Theme.of(context).charismaColor,
                          proficiency:
                              charProf.contains('charisma') ? profBonus : null,
                          onTap: editMode
                              ? () => editSavingThrow('Charisma')
                              : null,
                          onLongPress: () => editSavingThrow('Charisma'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
