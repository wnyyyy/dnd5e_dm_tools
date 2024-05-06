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
    required this.race,
    required this.name,
  });

  final Map<String, dynamic> character;
  final Map<String, dynamic> classs;
  final Map<String, dynamic> race;
  final String name;

  @override
  State<SavingThrowList> createState() => _SavingThrowListState();
}

class _SavingThrowListState extends State<SavingThrowList> {
  late List<String> char_prof;

  @override
  void initState() {
    super.initState();
    final profStr = widget.character['prof_saving_throws'] ??
        widget.classs['prof_saving_throws'];
    char_prof = profStr
        .toString()
        .toLowerCase()
        .split(',')
        .map((e) => e.trim())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final editMode = Provider.of<SettingsCubit>(context).state.isEditMode;
    final asi = widget.character['asi'];
    final profBonus = getProfBonus(widget.character['level']);

    void editSavingThrow(String attributeName) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final attr = attributeName.toLowerCase();
          bool isProficient = char_prof.contains(attr);
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
                          if (!char_prof.contains(attr)) {
                            char_prof.add(attr);
                          }
                        } else {
                          char_prof.remove(attr);
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
                          char_prof.join(',');
                      context.read<CharacterBloc>().add(CharacterUpdate(
                          character: widget.character,
                          race: widget.race,
                          classs: widget.classs,
                          name: widget.name));
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
                          attributeValue: asi['strength'],
                          color: Theme.of(context).strengthColor,
                          proficiency:
                              char_prof.contains('strength') ? profBonus : null,
                          onTap: editMode
                              ? () => editSavingThrow('Strength')
                              : null,
                        ),
                        const SizedBox(height: 12),
                        SavingThrow(
                          attributePrefix: 'DEX',
                          attributeValue: asi['dexterity'],
                          color: Theme.of(context).dexterityColor,
                          proficiency: char_prof.contains('dexterity')
                              ? profBonus
                              : null,
                          onTap: editMode
                              ? () => editSavingThrow('Dexterity')
                              : null,
                        ),
                        const SizedBox(height: 12),
                        SavingThrow(
                          attributePrefix: 'CON',
                          attributeValue: asi['constitution'],
                          color: Theme.of(context).constitutionColor,
                          proficiency: char_prof.contains('constitution')
                              ? profBonus
                              : null,
                          onTap: editMode
                              ? () => editSavingThrow('Constitution')
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        SavingThrow(
                          attributePrefix: 'INT',
                          attributeValue: asi['intelligence'],
                          color: Theme.of(context).intelligenceColor,
                          proficiency: char_prof.contains('intelligence')
                              ? profBonus
                              : null,
                          onTap: editMode
                              ? () => editSavingThrow('Intelligence')
                              : null,
                        ),
                        const SizedBox(height: 12),
                        SavingThrow(
                          attributePrefix: 'WIS',
                          attributeValue: asi['wisdom'],
                          color: Theme.of(context).wisdomColor,
                          proficiency:
                              char_prof.contains('wisdom') ? profBonus : null,
                          onTap:
                              editMode ? () => editSavingThrow('Wisdom') : null,
                        ),
                        const SizedBox(height: 12),
                        SavingThrow(
                          attributePrefix: 'CHA',
                          attributeValue: asi['charisma'],
                          color: Theme.of(context).charismaColor,
                          proficiency:
                              char_prof.contains('charisma') ? profBonus : null,
                          onTap: editMode
                              ? () => editSavingThrow('Charisma')
                              : null,
                        ),
                      ],
                    )
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
