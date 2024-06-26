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
  const SkillsTab({
    super.key,
    required this.character,
    required this.slug,
  });
  final Map<String, dynamic> character;
  final String slug;

  @override
  Widget build(BuildContext context) {
    final classs = context
        .read<RulesCubit>()
        .getClass(character['class'] as String? ?? '');
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
                  ),
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
    final asi = getAsi(character);

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
                    asi[attributeName.toLowerCase()] = newValue;
                    character['asi'] = asi;
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
          attributeValue: asi['strength'] ?? 10,
          color: Theme.of(context).strengthColor,
          onTap: editMode
              ? () => editAttribute('Strength', asi['strength'] ?? 10)
              : null,
          onLongPress: () => editAttribute('Strength', asi['strength'] ?? 10),
        ),
        AttributeCard(
          attributeName: 'Dexterity',
          attributeValue: asi['dexterity'] ?? 10,
          color: Theme.of(context).dexterityColor,
          onTap: editMode
              ? () => editAttribute('Dexterity', asi['dexterity'] ?? 10)
              : null,
          onLongPress: () => editAttribute('Dexterity', asi['dexterity'] ?? 10),
        ),
        AttributeCard(
          attributeName: 'Constitution',
          attributeValue: asi['constitution'] ?? 10,
          color: Theme.of(context).constitutionColor,
          onTap: editMode
              ? () => editAttribute(
                    'Constitution',
                    asi['constitution'] ?? 10,
                  )
              : null,
          onLongPress: () => editAttribute(
            'Constitution',
            asi['constitution'] ?? 10,
          ),
        ),
        AttributeCard(
          attributeName: 'Intelligence',
          attributeValue: asi['intelligence'] ?? 10,
          color: Theme.of(context).intelligenceColor,
          onTap: editMode
              ? () => editAttribute('Intelligence', asi['intelligence'] ?? 10)
              : null,
          onLongPress: () =>
              editAttribute('Intelligence', asi['intelligence'] ?? 10),
        ),
        AttributeCard(
          attributeName: 'Wisdom',
          attributeValue: asi['wisdom'] ?? 10,
          color: Theme.of(context).wisdomColor,
          onTap: editMode
              ? () => editAttribute('Wisdom', asi['wisdom'] ?? 10)
              : null,
          onLongPress: () => editAttribute('Wisdom', asi['wisdom'] ?? 10),
        ),
        AttributeCard(
          attributeName: 'Charisma',
          attributeValue: asi['charisma'] ?? 10,
          color: Theme.of(context).charismaColor,
          onTap: editMode
              ? () => editAttribute('Charisma', asi['charisma'] ?? 10)
              : null,
          onLongPress: () => editAttribute('Charisma', asi['charisma'] ?? 10),
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
                  '+${getProfBonus(character['level'] as int? ?? 1)}',
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
      text: character['passive_perception']?.toString() ?? '',
    );
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
                    child: Text(
                      '${character['passive_perception'] ?? 0}',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
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
