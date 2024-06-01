import 'package:dnd5e_dm_tools/core/config/app_colors.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab.dart/widgets/skill.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SkillList extends StatefulWidget {
  const SkillList({
    super.key,
    required this.character,
    required this.classs,
    required this.slug,
  });

  final Map<String, dynamic> character;
  final Map<String, dynamic> classs;
  final String slug;

  @override
  State<SkillList> createState() => _SkillListState();
}

class _SkillListState extends State<SkillList> {
  late List<String> skillProf;
  late List<String> expertiseSkills;

  @override
  void initState() {
    super.initState();
    final profSkills = widget.character['prof_skills'];
    if (profSkills != null && profSkills is List) {
      skillProf = List<String>.from(profSkills);
    } else {
      skillProf = [];
    }

    final expSkills = widget.character['expertise_skills'];
    if (expSkills != null && expSkills is List) {
      expertiseSkills = List<String>.from(expSkills);
    } else {
      expertiseSkills = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final editMode = Provider.of<SettingsCubit>(context).state.isEditMode;
    final profBonus = getProfBonus(widget.character['level'] as int? ?? 1);

    VoidCallback editSkill() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final List<String> skills = [
            'Acrobatics',
            'Animal Handling',
            'Arcana',
            'Athletics',
            'Deception',
            'History',
            'Insight',
            'Intimidation',
            'Investigation',
            'Medicine',
            'Nature',
            'Perception',
            'Performance',
            'Persuasion',
            'Religion',
            'Sleight of Hand',
            'Stealth',
            'Survival',
          ];

          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return AlertDialog(
                title: const Text('Edit Skill Proficiencies and Expertise'),
                content: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: skills.map((skill) {
                      final skillSlug =
                          skill.toLowerCase().trim().replaceAll(' ', '_');
                      return Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IntrinsicWidth(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(skill),
                                    ),
                                    Checkbox(
                                      value: skillProf.contains(skillSlug),
                                      onChanged: (bool? value) {
                                        if (value != null) {
                                          setDialogState(() {
                                            if (value) {
                                              if (!skillProf
                                                  .contains(skillSlug)) {
                                                skillProf.add(skillSlug);
                                              }
                                            } else {
                                              skillProf.removeWhere(
                                                (element) =>
                                                    element == skillSlug,
                                              );
                                              expertiseSkills.removeWhere(
                                                (element) =>
                                                    element == skillSlug,
                                              );
                                            }
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                if (skillProf.contains(skillSlug))
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      const Expanded(
                                        child: Text('Expertise'),
                                      ),
                                      Checkbox(
                                        value:
                                            expertiseSkills.contains(skillSlug),
                                        onChanged: (bool? value) {
                                          if (value != null) {
                                            setDialogState(() {
                                              if (value) {
                                                if (!expertiseSkills
                                                    .contains(skillSlug)) {
                                                  expertiseSkills
                                                      .add(skillSlug);
                                                }
                                              } else {
                                                expertiseSkills.removeWhere(
                                                  (element) =>
                                                      element == skillSlug,
                                                );
                                              }
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                              ],
                            ),
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
                      widget.character['prof_skills'] = skillProf;
                      widget.character['expertise_skills'] = expertiseSkills;
                      context.read<CharacterBloc>().add(
                            CharacterUpdate(
                              character: widget.character,
                              slug: widget.slug,
                              offline: context
                                  .read<SettingsCubit>()
                                  .state
                                  .offlineMode,
                              persistData: true,
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
      return () {};
    }

    return Card.outlined(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Skills',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: GestureDetector(
              onLongPress: () => editSkill(),
              onTap: editMode ? editSkill : null,
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
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(
                                    color: Theme.of(context).strengthColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Skill(
                              skillName: 'Athletics',
                              attributeName: 'Strength',
                              proficiency: skillProf.contains('athletics')
                                  ? profBonus
                                  : null,
                              expertise: expertiseSkills.contains('athletics'),
                              color: Theme.of(context).strengthColor,
                              character: widget.character,
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
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(
                                    color: Theme.of(context).dexterityColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Skill(
                              skillName: 'Acrobatics',
                              attributeName: 'Dexterity',
                              proficiency: skillProf.contains('acrobatics')
                                  ? profBonus
                                  : null,
                              expertise: expertiseSkills.contains('acrobatics'),
                              color: Theme.of(context).dexterityColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Sleight of Hand',
                              attributeName: 'Dexterity',
                              proficiency: skillProf.contains('sleight_of_hand')
                                  ? profBonus
                                  : null,
                              expertise:
                                  expertiseSkills.contains('sleight_of_hand'),
                              color: Theme.of(context).dexterityColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Stealth',
                              attributeName: 'Dexterity',
                              proficiency: skillProf.contains('stealth')
                                  ? profBonus
                                  : null,
                              expertise: expertiseSkills.contains('stealth'),
                              color: Theme.of(context).dexterityColor,
                              character: widget.character,
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
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(
                                    color: Theme.of(context).intelligenceColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Skill(
                              skillName: 'Arcana',
                              attributeName: 'Intelligence',
                              proficiency: skillProf.contains('arcana')
                                  ? profBonus
                                  : null,
                              expertise: expertiseSkills.contains('arcana'),
                              color: Theme.of(context).intelligenceColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'History',
                              attributeName: 'Intelligence',
                              proficiency: skillProf.contains('history')
                                  ? profBonus
                                  : null,
                              expertise: expertiseSkills.contains('history'),
                              color: Theme.of(context).intelligenceColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Investigation',
                              attributeName: 'Intelligence',
                              proficiency: skillProf.contains('investigation')
                                  ? profBonus
                                  : null,
                              expertise:
                                  expertiseSkills.contains('investigation'),
                              color: Theme.of(context).intelligenceColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Nature',
                              attributeName: 'Intelligence',
                              proficiency: skillProf.contains('nature')
                                  ? profBonus
                                  : null,
                              expertise: expertiseSkills.contains('nature'),
                              color: Theme.of(context).intelligenceColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Religion',
                              attributeName: 'Intelligence',
                              proficiency: skillProf.contains('religion')
                                  ? profBonus
                                  : null,
                              expertise: expertiseSkills.contains('religion'),
                              color: Theme.of(context).intelligenceColor,
                              character: widget.character,
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
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(
                                    color: Theme.of(context).wisdomColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Skill(
                              skillName: 'Animal Handling',
                              attributeName: 'Wisdom',
                              proficiency: skillProf.contains('animal_handling')
                                  ? profBonus
                                  : null,
                              expertise:
                                  expertiseSkills.contains('animal_handling'),
                              color: Theme.of(context).wisdomColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Insight',
                              attributeName: 'Wisdom',
                              proficiency: skillProf.contains('insight')
                                  ? profBonus
                                  : null,
                              expertise: expertiseSkills.contains('insight'),
                              color: Theme.of(context).wisdomColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Medicine',
                              attributeName: 'Wisdom',
                              proficiency: skillProf.contains('medicine')
                                  ? profBonus
                                  : null,
                              expertise: expertiseSkills.contains('medicine'),
                              color: Theme.of(context).wisdomColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Perception',
                              attributeName: 'Wisdom',
                              proficiency: skillProf.contains('perception')
                                  ? profBonus
                                  : null,
                              expertise: expertiseSkills.contains('perception'),
                              color: Theme.of(context).wisdomColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Survival',
                              attributeName: 'Wisdom',
                              proficiency: skillProf.contains('survival')
                                  ? profBonus
                                  : null,
                              expertise: expertiseSkills.contains('survival'),
                              color: Theme.of(context).wisdomColor,
                              character: widget.character,
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
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(
                                    color: Theme.of(context).charismaColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Skill(
                              skillName: 'Deception',
                              attributeName: 'Charisma',
                              proficiency: skillProf.contains('deception')
                                  ? profBonus
                                  : null,
                              expertise: expertiseSkills.contains('deception'),
                              color: Theme.of(context).charismaColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Intimidation',
                              attributeName: 'Charisma',
                              proficiency: skillProf.contains('intimidation')
                                  ? profBonus
                                  : null,
                              expertise:
                                  expertiseSkills.contains('intimidation'),
                              color: Theme.of(context).charismaColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Performance',
                              attributeName: 'Charisma',
                              proficiency: skillProf.contains('performance')
                                  ? profBonus
                                  : null,
                              expertise:
                                  expertiseSkills.contains('performance'),
                              color: Theme.of(context).charismaColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Persuasion',
                              attributeName: 'Charisma',
                              proficiency: skillProf.contains('persuasion')
                                  ? profBonus
                                  : null,
                              expertise: expertiseSkills.contains('persuasion'),
                              color: Theme.of(context).charismaColor,
                              character: widget.character,
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
        ],
      ),
    );
  }
}
