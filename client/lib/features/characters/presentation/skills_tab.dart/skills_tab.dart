import 'package:dnd5e_dm_tools/core/config/app_colors.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab.dart/widgets/attribute.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab.dart/widgets/saving_throw.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab.dart/widgets/saving_throw_list.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SkillsTab extends StatelessWidget {
  final Map<String, dynamic> character;
  final Map<String, dynamic> race;
  final Map<String, dynamic> classs;
  final String name;

  const SkillsTab({
    super.key,
    required this.character,
    required this.name,
    required this.race,
    required this.classs,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Flex(
          direction: Axis.horizontal,
          children: [
            _buildAttributesList(context),
            SizedBox(width: 8),
            Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildProficiencyBonus(context),
                  SavingThrowList(
                      character: character,
                      classs: classs,
                      race: race,
                      name: name)
                ]),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributesList(BuildContext context) {
    final editMode = Provider.of<SettingsCubit>(context).state.isEditMode;
    final asi = character['asi'];

    void editAttribute(String attributeName, int currentValue) {
      final TextEditingController _controller =
          TextEditingController(text: currentValue.toString());
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit $attributeName'),
            content: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter new value',
              ),
              controller: _controller,
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              TextButton(
                child: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Icon(Icons.check),
                onPressed: () {
                  final newValue = int.tryParse(_controller.text);
                  if (newValue != null &&
                      newValue != currentValue &&
                      newValue >= 0) {
                    character['asi'][attributeName.toLowerCase()] = newValue;
                    context.read<CharacterBloc>().add(CharacterUpdate(
                        character: character,
                        race: race,
                        classs: classs,
                        name: name));
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    }

    return Flex(
      direction: Axis.vertical,
      children: [
        AttributeCard(
          attributeName: 'Strength',
          attributeValue: asi['strength'],
          color: Theme.of(context).strengthColor,
          onTap: editMode
              ? () => editAttribute('Strength', asi['strength'])
              : null,
        ),
        AttributeCard(
          attributeName: 'Dexterity',
          attributeValue: asi['dexterity'],
          color: Theme.of(context).dexterityColor,
          onTap: editMode
              ? () => editAttribute('Dexterity', asi['dexterity'])
              : null,
        ),
        AttributeCard(
          attributeName: 'Constitution',
          attributeValue: asi['constitution'],
          color: Theme.of(context).constitutionColor,
          onTap: editMode
              ? () => editAttribute('Constitution', asi['constitution'])
              : null,
        ),
        AttributeCard(
          attributeName: 'Intelligence',
          attributeValue: asi['intelligence'],
          color: Theme.of(context).intelligenceColor,
          onTap: editMode
              ? () => editAttribute('Intelligence', asi['intelligence'])
              : null,
        ),
        AttributeCard(
          attributeName: 'Wisdom',
          attributeValue: asi['wisdom'],
          color: Theme.of(context).wisdomColor,
          onTap: editMode ? () => editAttribute('Wisdom', asi['wisdom']) : null,
        ),
        AttributeCard(
          attributeName: 'Charisma',
          attributeValue: asi['charisma'],
          color: Theme.of(context).charismaColor,
          onTap: editMode
              ? () => editAttribute('Charisma', asi['charisma'])
              : null,
        ),
      ],
    );
  }

  Widget _buildProficiencyBonus(BuildContext context) {
    return Card.outlined(
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 4),
            child: Text(
              'Proficiency\nBonus',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Text(
                  '+${getProfBonus(character['level'])}',
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        fontFamily: GoogleFonts.majorMonoDisplay().fontFamily,
                      ),
                ),
                Icon(
                  Icons.star_outline,
                  size: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingThrowList(BuildContext context) {
    final editMode = Provider.of<SettingsCubit>(context).state.isEditMode;
    final asi = character['asi'];
    final proficiencies = classs['prof_saving_throws'].toString().toLowerCase();
    final profBonus = getProfBonus(character['level']);

    void editSavingThrow(String attributeName, int currentValue) {
      final TextEditingController _controller =
          TextEditingController(text: currentValue.toString());
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit $attributeName Saving Throw'),
            content: CheckboxListTile(
              title: Text('Proficient'),
              value: proficiencies.contains(attributeName.toLowerCase()),
              onChanged: (value) {
                if (value != null) {
                  if (value) {
                    var profs =
                        classs['prof_saving_throws'].toString().split(',');
                    profs.add(attributeName);
                    classs['prof_saving_throws'] = profs.join(',');
                  } else {
                    final profs =
                        classs['prof_saving_throws'].toString().split(',');
                    final newProfs = profs.where((element) {
                      return element.toLowerCase() !=
                          attributeName.toLowerCase();
                    });
                    classs['prof_saving_throws'] = newProfs.join(',');
                  }
                  context.read<CharacterBloc>().add(CharacterUpdate(
                        character: character,
                        race: race,
                        classs: classs,
                        name: name,
                      ));
                }
              },
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              TextButton(
                child: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Icon(Icons.check),
                onPressed: () {
                  final newValue = int.tryParse(_controller.text);
                  if (newValue != null &&
                      newValue != currentValue &&
                      newValue >= 0) {
                    character['asi'][attributeName.toLowerCase()] = newValue;
                    context.read<CharacterBloc>().add(CharacterUpdate(
                        character: character,
                        race: race,
                        classs: classs,
                        name: name));
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
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
                          proficiency: proficiencies.contains('strength')
                              ? profBonus
                              : null,
                          onTap: editMode
                              ? () =>
                                  editSavingThrow('Strength', asi['strength'])
                              : null,
                        ),
                        SizedBox(height: 12),
                        SavingThrow(
                          attributePrefix: 'DEX',
                          attributeValue: asi['dexterity'],
                          color: Theme.of(context).dexterityColor,
                          proficiency: proficiencies.contains('dexterity')
                              ? profBonus
                              : null,
                          onTap: editMode
                              ? () =>
                                  editSavingThrow('Dexterity', asi['dexterity'])
                              : null,
                        ),
                        SizedBox(height: 12),
                        SavingThrow(
                          attributePrefix: 'CON',
                          attributeValue: asi['constitution'],
                          color: Theme.of(context).constitutionColor,
                          proficiency: proficiencies.contains('constitution')
                              ? profBonus
                              : null,
                          onTap: editMode
                              ? () => editSavingThrow(
                                  'Constitution', asi['constitution'])
                              : null,
                        ),
                      ],
                    ),
                    SizedBox(width: 8),
                    Column(
                      children: [
                        SavingThrow(
                          attributePrefix: 'INT',
                          attributeValue: asi['intelligence'],
                          color: Theme.of(context).intelligenceColor,
                          proficiency: proficiencies.contains('intelligence')
                              ? profBonus
                              : null,
                          onTap: editMode
                              ? () => editSavingThrow(
                                  'Intelligence', asi['intelligence'])
                              : null,
                        ),
                        SizedBox(height: 12),
                        SavingThrow(
                          attributePrefix: 'WIS',
                          attributeValue: asi['wisdom'],
                          color: Theme.of(context).wisdomColor,
                          proficiency: proficiencies.contains('wisdom')
                              ? profBonus
                              : null,
                          onTap: editMode
                              ? () => editSavingThrow('Wisdom', asi['wisdom'])
                              : null,
                        ),
                        SizedBox(height: 12),
                        SavingThrow(
                          attributePrefix: 'CHA',
                          attributeValue: asi['charisma'],
                          color: Theme.of(context).charismaColor,
                          proficiency: proficiencies.contains('charisma')
                              ? profBonus
                              : null,
                          onTap: editMode
                              ? () =>
                                  editSavingThrow('Charisma', asi['charisma'])
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
