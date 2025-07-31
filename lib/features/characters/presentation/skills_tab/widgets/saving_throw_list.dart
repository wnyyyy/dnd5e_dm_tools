import 'package:dnd5e_dm_tools/core/config/app_colors.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab/widgets/saving_throw.dart';
import 'package:flutter/material.dart';

class SavingThrowList extends StatelessWidget {
  const SavingThrowList({
    super.key,
    required this.character,
    required this.classs,
  });

  final Character character;
  final Class classs;

  @override
  Widget build(BuildContext context) {
    final asi = character.asi;
    final profBonus = ((character.level - 1) ~/ 4) + 2;
    final savingThrows = <Attribute>{
      ...classs.proficiency.savingThrows,
      ...character.proficiency.savingThrows,
    };

    Widget savingThrow(Attribute attr, String prefix, Color color) {
      return SavingThrow(
        attributePrefix: prefix,
        attributeValue: asi.fromAttribute(attr),
        color: color,
        proficiency: savingThrows.contains(attr) ? profBonus : null,
      );
    }

    return Card.outlined(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Saving Throws',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    savingThrow(
                      Attribute.strength,
                      'STR',
                      Theme.of(context).strengthColor,
                    ),
                    const SizedBox(height: 12),
                    savingThrow(
                      Attribute.dexterity,
                      'DEX',
                      Theme.of(context).dexterityColor,
                    ),
                    const SizedBox(height: 12),
                    savingThrow(
                      Attribute.constitution,
                      'CON',
                      Theme.of(context).constitutionColor,
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    savingThrow(
                      Attribute.intelligence,
                      'INT',
                      Theme.of(context).intelligenceColor,
                    ),
                    const SizedBox(height: 12),
                    savingThrow(
                      Attribute.wisdom,
                      'WIS',
                      Theme.of(context).wisdomColor,
                    ),
                    const SizedBox(height: 12),
                    savingThrow(
                      Attribute.charisma,
                      'CHA',
                      Theme.of(context).charismaColor,
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
