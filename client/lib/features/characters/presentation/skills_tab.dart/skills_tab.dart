import 'package:dnd5e_dm_tools/core/config/app_colors.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab.dart/widgets/attribute.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab.dart/widgets/saving_throw_list.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab.dart/widgets/skills_list.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SkillsTab extends StatelessWidget {
  final Map<String, dynamic> character;
  final String slug;

  const SkillsTab({
    super.key,
    required this.character,
    required this.slug,
  });

  @override
  Widget build(BuildContext context) {
    final classs = context.read<RulesCubit>().getClass(character['class']);
    if (classs == null) {
      return const Center(
        child: Text('Class not found'),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildAttributesList(context),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      _buildProficiencyBonus(context),
                      SavingThrowList(
                        character: character,
                        slug: slug,
                        classs: classs,
                      ),
                      _buildPassivePerception(context),
                    ],
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: constraints.maxWidth * 0.3 + 100,
                    child: SkillList(
                      character: character,
                      classs: classs,
                      slug: slug,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAttributesList(context),
                      const SizedBox(width: 8),
                      Flex(
                        direction: Axis.vertical,
                        children: [
                          _buildProficiencyBonus(context),
                          SavingThrowList(
                            character: character,
                            slug: slug,
                            classs: classs,
                          ),
                          _buildPassivePerception(context),
                        ],
                      ),
                    ],
                  ),
                  SkillList(
                    character: character,
                    classs: classs,
                    slug: slug,
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildAttributesList(BuildContext context) {
    final editMode = Provider.of<SettingsCubit>(context).state.isEditMode;
    final asi = character['asi'];

    void editAttribute(String attributeName, int currentValue) {
      final TextEditingController controller =
          TextEditingController(text: currentValue.toString());
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit $attributeName'),
            content: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter new value',
              ),
              controller: controller,
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
                  final newValue = int.tryParse(controller.text);
                  if (newValue != null &&
                      newValue != currentValue &&
                      newValue >= 0) {
                    character['asi'][attributeName.toLowerCase()] = newValue;
                    context.read<CharacterBloc>().add(CharacterUpdate(
                          character: character,
                          slug: slug,
                          offline:
                              context.read<SettingsCubit>().state.offlineMode,
                          persistData: true,
                        ));
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
          onLongPress: () => editAttribute('Strength', asi['strength']),
        ),
        AttributeCard(
          attributeName: 'Dexterity',
          attributeValue: asi['dexterity'],
          color: Theme.of(context).dexterityColor,
          onTap: editMode
              ? () => editAttribute('Dexterity', asi['dexterity'])
              : null,
          onLongPress: () => editAttribute('Dexterity', asi['dexterity']),
        ),
        AttributeCard(
          attributeName: 'Constitution',
          attributeValue: asi['constitution'],
          color: Theme.of(context).constitutionColor,
          onTap: editMode
              ? () => editAttribute('Constitution', asi['constitution'])
              : null,
          onLongPress: () => editAttribute('Constitution', asi['constitution']),
        ),
        AttributeCard(
          attributeName: 'Intelligence',
          attributeValue: asi['intelligence'],
          color: Theme.of(context).intelligenceColor,
          onTap: editMode
              ? () => editAttribute('Intelligence', asi['intelligence'])
              : null,
          onLongPress: () => editAttribute('Intelligence', asi['intelligence']),
        ),
        AttributeCard(
          attributeName: 'Wisdom',
          attributeValue: asi['wisdom'],
          color: Theme.of(context).wisdomColor,
          onTap: editMode ? () => editAttribute('Wisdom', asi['wisdom']) : null,
          onLongPress: () => editAttribute('Wisdom', asi['wisdom']),
        ),
        AttributeCard(
          attributeName: 'Charisma',
          attributeValue: asi['charisma'],
          color: Theme.of(context).charismaColor,
          onTap: editMode
              ? () => editAttribute('Charisma', asi['charisma'])
              : null,
          onLongPress: () => editAttribute('Charisma', asi['charisma']),
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
                const Icon(
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

  void _showEditPassivePerception(BuildContext context) {
    final TextEditingController controller = TextEditingController(
        text: character['passive_perception']?.toString() ?? '');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Passive Perception'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter new value',
            ),
            controller: controller,
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
                final newValue = int.tryParse(controller.text);
                if (newValue != null &&
                    newValue != character['passive_perception'] &&
                    newValue >= 0) {
                  character['passive_perception'] = newValue;
                  context.read<CharacterBloc>().add(CharacterUpdate(
                        character: character,
                        slug: slug,
                        offline:
                            context.read<SettingsCubit>().state.offlineMode,
                        persistData: true,
                      ));
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPassivePerception(BuildContext context) {
    final editMode = Provider.of<SettingsCubit>(context).state.isEditMode;
    return Card.outlined(
      child: GestureDetector(
        onLongPress: () => _showEditPassivePerception(context),
        onTap: editMode ? () => _showEditPassivePerception(context) : null,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 4),
              child: Text(
                'Passive\nPerception',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text('${character['passive_perception'] ?? 0}',
                        style: Theme.of(context).textTheme.displaySmall),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.search_outlined,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
