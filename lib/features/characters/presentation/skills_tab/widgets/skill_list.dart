import 'package:dnd5e_dm_tools/core/config/app_colors.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_event.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab/widgets/skill_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SkillList extends StatelessWidget {
  const SkillList({super.key, required this.character, required this.classs});

  final Character character;
  final Class classs;

  @override
  Widget build(BuildContext context) {
    final charSkills = character.proficiency.skills;
    final profBonus = getProfBonus(character.level);

    void editSkill() {
      final editedSkills = Map<Skill, ProficiencyLevel>.from(charSkills);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              final Map<Attribute, List<Skill>> skillsByAttr = {};
              for (final skill in Skill.values) {
                skillsByAttr.putIfAbsent(skill.attribute, () => []).add(skill);
              }

              Color attrColor(Attribute attr) {
                switch (attr) {
                  case Attribute.strength:
                    return Theme.of(context).strengthColor;
                  case Attribute.dexterity:
                    return Theme.of(context).dexterityColor;
                  case Attribute.constitution:
                    return Theme.of(context).constitutionColor;
                  case Attribute.intelligence:
                    return Theme.of(context).intelligenceColor;
                  case Attribute.wisdom:
                    return Theme.of(context).wisdomColor;
                  case Attribute.charisma:
                    return Theme.of(context).charismaColor;
                }
              }

              return AlertDialog(
                title: const Text('Edit Skill Proficiencies and Expertise'),
                content: SingleChildScrollView(
                  child: Column(
                    children: Attribute.values.map((attr) {
                      if (attr == Attribute.constitution) {
                        return const SizedBox.shrink();
                      }
                      final skills = skillsByAttr[attr] ?? [];
                      return Card.outlined(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                attr.name,
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(
                                      color: attrColor(attr),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              ...skills.asMap().entries.map((entry) {
                                final i = entry.key;
                                final skill = entry.value;
                                final prof = editedSkills[skill];
                                final hasProf =
                                    prof == ProficiencyLevel.proficient ||
                                    prof == ProficiencyLevel.expert;
                                final isLast = i == skills.length - 1;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2.0,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 140,
                                            child: Text(
                                              skill.name,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Checkbox(
                                                    value: hasProf,
                                                    onChanged: (bool? value) {
                                                      if (value != null) {
                                                        setDialogState(() {
                                                          if (value) {
                                                            editedSkills[skill] =
                                                                ProficiencyLevel
                                                                    .proficient;
                                                          } else {
                                                            editedSkills[skill] =
                                                                ProficiencyLevel
                                                                    .none;
                                                          }
                                                        });
                                                      }
                                                    },
                                                  ),
                                                  const Text('Proficient'),
                                                ],
                                              ),
                                              if (hasProf)
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Checkbox(
                                                      value:
                                                          prof ==
                                                          ProficiencyLevel
                                                              .expert,
                                                      onChanged: (bool? value) {
                                                        if (value != null) {
                                                          setDialogState(() {
                                                            if (value) {
                                                              editedSkills[skill] =
                                                                  ProficiencyLevel
                                                                      .expert;
                                                            } else {
                                                              editedSkills[skill] =
                                                                  ProficiencyLevel
                                                                      .proficient;
                                                            }
                                                          });
                                                        }
                                                      },
                                                    ),
                                                    const Text('Expertise'),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (!isLast)
                                        Divider(
                                          color: Theme.of(
                                            context,
                                          ).dividerColor.withAlpha(64),
                                          height: 12,
                                          thickness: 1,
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
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
                      context.read<CharacterBloc>().add(
                        CharacterUpdate(
                          persistData: true,
                          character: character.copyWith(
                            proficiency: character.proficiency.copyWith(
                              skills: editedSkills,
                            ),
                          ),
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

    return GestureDetector(
      onLongPress: editSkill,
      child: Card.outlined(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Strength',
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(
                                color: Theme.of(context).strengthColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        SkillWidget(
                          proficiency:
                              (charSkills[Skill.athletics] ==
                                      ProficiencyLevel.proficient ||
                                  charSkills[Skill.athletics] ==
                                      ProficiencyLevel.expert)
                              ? profBonus
                              : null,
                          hasExpertise:
                              charSkills[Skill.athletics] ==
                              ProficiencyLevel.expert,
                          color: Theme.of(context).strengthColor,
                          skill: Skill.athletics,
                          attributeValue: character.asi.strength,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Dexterity',
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(
                                color: Theme.of(context).dexterityColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        SkillWidget(
                          proficiency:
                              (charSkills[Skill.acrobatics] ==
                                      ProficiencyLevel.proficient ||
                                  charSkills[Skill.acrobatics] ==
                                      ProficiencyLevel.expert)
                              ? profBonus
                              : null,
                          hasExpertise:
                              charSkills[Skill.acrobatics] ==
                              ProficiencyLevel.expert,
                          color: Theme.of(context).dexterityColor,
                          skill: Skill.acrobatics,
                          attributeValue: character.asi.dexterity,
                        ),
                        SkillWidget(
                          proficiency:
                              (charSkills[Skill.sleightOfHand] ==
                                      ProficiencyLevel.proficient ||
                                  charSkills[Skill.sleightOfHand] ==
                                      ProficiencyLevel.expert)
                              ? profBonus
                              : null,
                          hasExpertise:
                              charSkills[Skill.sleightOfHand] ==
                              ProficiencyLevel.expert,
                          color: Theme.of(context).dexterityColor,
                          skill: Skill.sleightOfHand,
                          attributeValue: character.asi.dexterity,
                        ),
                        SkillWidget(
                          proficiency:
                              (charSkills[Skill.stealth] ==
                                      ProficiencyLevel.proficient ||
                                  charSkills[Skill.stealth] ==
                                      ProficiencyLevel.expert)
                              ? profBonus
                              : null,
                          hasExpertise:
                              charSkills[Skill.stealth] ==
                              ProficiencyLevel.expert,
                          color: Theme.of(context).dexterityColor,
                          skill: Skill.stealth,
                          attributeValue: character.asi.dexterity,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Intelligence',
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(
                                color: Theme.of(context).intelligenceColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        SkillWidget(
                          skill: Skill.arcana,
                          attributeValue: character.asi.intelligence,
                          proficiency:
                              (charSkills[Skill.arcana] ==
                                      ProficiencyLevel.proficient ||
                                  charSkills[Skill.arcana] ==
                                      ProficiencyLevel.expert)
                              ? profBonus
                              : null,
                          hasExpertise:
                              charSkills[Skill.arcana] ==
                              ProficiencyLevel.expert,
                          color: Theme.of(context).intelligenceColor,
                        ),
                        SkillWidget(
                          skill: Skill.history,
                          attributeValue: character.asi.intelligence,
                          proficiency:
                              (charSkills[Skill.history] ==
                                      ProficiencyLevel.proficient ||
                                  charSkills[Skill.history] ==
                                      ProficiencyLevel.expert)
                              ? profBonus
                              : null,
                          hasExpertise:
                              charSkills[Skill.history] ==
                              ProficiencyLevel.expert,
                          color: Theme.of(context).intelligenceColor,
                        ),
                        SkillWidget(
                          skill: Skill.investigation,
                          attributeValue: character.asi.intelligence,
                          proficiency:
                              (charSkills[Skill.investigation] ==
                                      ProficiencyLevel.proficient ||
                                  charSkills[Skill.investigation] ==
                                      ProficiencyLevel.expert)
                              ? profBonus
                              : null,
                          hasExpertise:
                              charSkills[Skill.investigation] ==
                              ProficiencyLevel.expert,
                          color: Theme.of(context).intelligenceColor,
                        ),
                        SkillWidget(
                          skill: Skill.nature,
                          attributeValue: character.asi.intelligence,
                          proficiency:
                              (charSkills[Skill.nature] ==
                                      ProficiencyLevel.proficient ||
                                  charSkills[Skill.nature] ==
                                      ProficiencyLevel.expert)
                              ? profBonus
                              : null,
                          hasExpertise:
                              charSkills[Skill.nature] ==
                              ProficiencyLevel.expert,
                          color: Theme.of(context).intelligenceColor,
                        ),
                        SkillWidget(
                          skill: Skill.religion,
                          attributeValue: character.asi.intelligence,
                          proficiency:
                              (charSkills[Skill.religion] ==
                                      ProficiencyLevel.proficient ||
                                  charSkills[Skill.religion] ==
                                      ProficiencyLevel.expert)
                              ? profBonus
                              : null,
                          hasExpertise:
                              charSkills[Skill.religion] ==
                              ProficiencyLevel.expert,
                          color: Theme.of(context).intelligenceColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Wisdom',
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(
                                color: Theme.of(context).wisdomColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        SkillWidget(
                          skill: Skill.animalHandling,
                          attributeValue: character.asi.wisdom,
                          proficiency:
                              (charSkills[Skill.animalHandling] ==
                                      ProficiencyLevel.proficient ||
                                  charSkills[Skill.animalHandling] ==
                                      ProficiencyLevel.expert)
                              ? profBonus
                              : null,
                          hasExpertise:
                              charSkills[Skill.animalHandling] ==
                              ProficiencyLevel.expert,
                          color: Theme.of(context).wisdomColor,
                        ),
                        SkillWidget(
                          skill: Skill.insight,
                          attributeValue: character.asi.wisdom,
                          proficiency:
                              (charSkills[Skill.insight] ==
                                      ProficiencyLevel.proficient ||
                                  charSkills[Skill.insight] ==
                                      ProficiencyLevel.expert)
                              ? profBonus
                              : null,
                          hasExpertise:
                              charSkills[Skill.insight] ==
                              ProficiencyLevel.expert,
                          color: Theme.of(context).wisdomColor,
                        ),
                        SkillWidget(
                          skill: Skill.medicine,
                          attributeValue: character.asi.wisdom,
                          proficiency:
                              (charSkills[Skill.medicine] ==
                                      ProficiencyLevel.proficient ||
                                  charSkills[Skill.medicine] ==
                                      ProficiencyLevel.expert)
                              ? profBonus
                              : null,
                          hasExpertise:
                              charSkills[Skill.medicine] ==
                              ProficiencyLevel.expert,
                          color: Theme.of(context).wisdomColor,
                        ),
                        SkillWidget(
                          skill: Skill.perception,
                          attributeValue: character.asi.wisdom,
                          proficiency:
                              (charSkills[Skill.perception] ==
                                      ProficiencyLevel.proficient ||
                                  charSkills[Skill.perception] ==
                                      ProficiencyLevel.expert)
                              ? profBonus
                              : null,
                          hasExpertise:
                              charSkills[Skill.perception] ==
                              ProficiencyLevel.expert,
                          color: Theme.of(context).wisdomColor,
                        ),
                        SkillWidget(
                          skill: Skill.survival,
                          attributeValue: character.asi.wisdom,
                          proficiency:
                              (charSkills[Skill.survival] ==
                                      ProficiencyLevel.proficient ||
                                  charSkills[Skill.survival] ==
                                      ProficiencyLevel.expert)
                              ? profBonus
                              : null,
                          hasExpertise:
                              charSkills[Skill.survival] ==
                              ProficiencyLevel.expert,
                          color: Theme.of(context).wisdomColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Charisma',
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(
                                color: Theme.of(context).charismaColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 2),
                        SkillWidget(
                          skill: Skill.deception,
                          attributeValue: character.asi.charisma,
                          proficiency:
                              (charSkills[Skill.deception] ==
                                      ProficiencyLevel.proficient ||
                                  charSkills[Skill.deception] ==
                                      ProficiencyLevel.expert)
                              ? profBonus
                              : null,
                          hasExpertise:
                              charSkills[Skill.deception] ==
                              ProficiencyLevel.expert,
                          color: Theme.of(context).charismaColor,
                        ),
                        SkillWidget(
                          skill: Skill.intimidation,
                          attributeValue: character.asi.charisma,
                          proficiency:
                              (charSkills[Skill.intimidation] ==
                                      ProficiencyLevel.proficient ||
                                  charSkills[Skill.intimidation] ==
                                      ProficiencyLevel.expert)
                              ? profBonus
                              : null,
                          hasExpertise:
                              charSkills[Skill.intimidation] ==
                              ProficiencyLevel.expert,
                          color: Theme.of(context).charismaColor,
                        ),
                        SkillWidget(
                          skill: Skill.performance,
                          attributeValue: character.asi.charisma,
                          proficiency:
                              (charSkills[Skill.performance] ==
                                      ProficiencyLevel.proficient ||
                                  charSkills[Skill.performance] ==
                                      ProficiencyLevel.expert)
                              ? profBonus
                              : null,
                          hasExpertise:
                              charSkills[Skill.performance] ==
                              ProficiencyLevel.expert,
                          color: Theme.of(context).charismaColor,
                        ),
                        SkillWidget(
                          skill: Skill.persuasion,
                          attributeValue: character.asi.charisma,
                          proficiency:
                              (charSkills[Skill.persuasion] ==
                                      ProficiencyLevel.proficient ||
                                  charSkills[Skill.persuasion] ==
                                      ProficiencyLevel.expert)
                              ? profBonus
                              : null,
                          hasExpertise:
                              charSkills[Skill.persuasion] ==
                              ProficiencyLevel.expert,
                          color: Theme.of(context).charismaColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
