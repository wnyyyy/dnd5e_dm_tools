import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab/widgets/attributes_column.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab/widgets/passive_perception_card.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab/widgets/proficiency_bonus_card.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab/widgets/saving_throw_list.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab/widgets/skill_list.dart';
import 'package:flutter/material.dart';

class SkillsTab extends StatelessWidget {
  const SkillsTab({super.key, required this.character, required this.classs});

  final Character character;
  final Class classs;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AttributesColumn(character: character),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          ProficiencyBonusCard(character: character),
                          SavingThrowList(character: character, classs: classs),
                          PassivePerceptionCard(character: character),
                        ],
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: constraints.maxWidth * 0.3 + 100,
                        child: SkillList(character: character, classs: classs),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AttributesColumn(character: character),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              ProficiencyBonusCard(character: character),
                              SavingThrowList(
                                character: character,
                                classs: classs,
                              ),
                              PassivePerceptionCard(character: character),
                            ],
                          ),
                        ],
                      ),
                      SkillList(character: character, classs: classs),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
