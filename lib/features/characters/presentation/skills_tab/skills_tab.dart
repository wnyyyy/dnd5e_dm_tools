import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab/widgets/attributes_column.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab/widgets/saving_throw_list.dart';
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
                          _ProficiencyBonus(character: character),
                          SavingThrowList(character: character, classs: classs),
                          _PassivePerception(character: character),
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
                              _ProficiencyBonus(character: character),
                              SavingThrowList(
                                character: character,
                                classs: classs,
                              ),
                              _PassivePerception(character: character),
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

class SkillList extends StatelessWidget {
  const SkillList({required this.character, required this.classs});

  final Character character;
  final Class classs;

  @override
  Widget build(BuildContext context) {
    // Implement your skill list widget here
    // This is a placeholder for the actual implementation
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Skills List for ${character.name}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _ProficiencyBonus extends StatelessWidget {
  const _ProficiencyBonus({required this.character});
  final Character character;

  @override
  Widget build(BuildContext context) {
    // Replace with your actual proficiency bonus logic if needed
    final bonus = ((character.level - 1) ~/ 4) + 2;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Proficiency Bonus: +$bonus',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _PassivePerception extends StatelessWidget {
  const _PassivePerception({required this.character});
  final Character character;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Passive Perception: ${character.characterStats.passivePerception}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
