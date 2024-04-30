import 'package:dnd5e_dm_tools/core/config/app_colors.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab.dart/widgets/attribute.dart';
import 'package:flutter/material.dart';

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
      child: Flex(
        direction: Axis.vertical,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 32),
            child: _buildAttributesList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributesList(BuildContext context) {
    final asi = character['asi'];
    return Flex(
      direction: Axis.vertical,
      children: [
        AttributeCard(
          attributeName: 'Strength',
          attributeValue: asi['strength'],
          color: Theme.of(context).strengthColor,
        ),
        AttributeCard(
          attributeName: 'Dexterity',
          attributeValue: asi['dexterity'],
          color: Theme.of(context).dexterityColor,
        ),
        AttributeCard(
          attributeName: 'Constitution',
          attributeValue: asi['constitution'],
          color: Theme.of(context).constitutionColor,
        ),
        AttributeCard(
          attributeName: 'Intelligence',
          attributeValue: asi['intelligence'],
          color: Theme.of(context).intelligenceColor,
        ),
        AttributeCard(
          attributeName: 'Wisdom',
          attributeValue: asi['wisdom'],
          color: Theme.of(context).wisdomColor,
        ),
        AttributeCard(
          attributeName: 'Charisma',
          attributeValue: asi['charisma'],
          color: Theme.of(context).charismaColor,
        ),
      ],
    );
  }
}
