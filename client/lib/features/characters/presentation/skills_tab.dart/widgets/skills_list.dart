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
    required this.name,
  });

  final Map<String, dynamic> character;
  final Map<String, dynamic> classs;
  final String name;

  @override
  State<SkillList> createState() => _SkillListState();
}

class _SkillListState extends State<SkillList> {
  late List<String> skillProf;

  @override
  void initState() {
    super.initState();
    var profSkills = widget.character['prof_skills'];
    if (profSkills != null && profSkills is List) {
      skillProf = List<String>.from(profSkills);
    } else {
      skillProf = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final editMode = Provider.of<SettingsCubit>(context).state.isEditMode;
    final profBonus = getProfBonus(widget.character['level']);

    VoidCallback editSkill() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          List<String> skills = [
            "Acrobatics",
            "Animal Handling",
            "Arcana",
            "Athletics",
            "Deception",
            "History",
            "Insight",
            "Intimidation",
            "Investigation",
            "Medicine",
            "Nature",
            "Perception",
            "Performance",
            "Persuasion",
            "Religion",
            "Sleight of Hand",
            "Stealth",
            "Survival"
          ];

          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return AlertDialog(
                title: const Text('Edit Skill Proficiencies'),
                content: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  children: skills.map((skill) {
                    final skillSlug =
                        skill.toLowerCase().trim().replaceAll(' ', '_');
                    return Row(
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
                                  if (!skillProf.contains(skillSlug)) {
                                    skillProf.add(skillSlug);
                                  }
                                } else {
                                  skillProf.removeWhere(
                                      (element) => element == skillSlug);
                                }
                              });
                            }
                          },
                        ),
                      ],
                    );
                  }).toList(),
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
                      context.read<CharacterBloc>().add(CharacterUpdate(
                            character: widget.character,
                            name: widget.name,
                          ));
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
                            Text('Strength',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                        color: Theme.of(context).strengthColor,
                                        fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Skill(
                              skillName: 'Athletics',
                              attributeName: 'Strength',
                              proficiency: skillProf.contains('athletics')
                                  ? profBonus
                                  : null,
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
                            Text('Dexterity',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                        color: Theme.of(context).dexterityColor,
                                        fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Skill(
                              skillName: 'Acrobatics',
                              attributeName: 'Dexterity',
                              proficiency: skillProf.contains('acrobatics')
                                  ? profBonus
                                  : null,
                              color: Theme.of(context).dexterityColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Sleight of Hand',
                              attributeName: 'Dexterity',
                              proficiency: skillProf.contains('sleight_of_hand')
                                  ? profBonus
                                  : null,
                              color: Theme.of(context).dexterityColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Stealth',
                              attributeName: 'Dexterity',
                              proficiency: skillProf.contains('stealth')
                                  ? profBonus
                                  : null,
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
                            Text('Intelligence',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                        color:
                                            Theme.of(context).intelligenceColor,
                                        fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Skill(
                              skillName: 'Arcana',
                              attributeName: 'Intelligence',
                              proficiency: skillProf.contains('arcana')
                                  ? profBonus
                                  : null,
                              color: Theme.of(context).intelligenceColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'History',
                              attributeName: 'Intelligence',
                              proficiency: skillProf.contains('history')
                                  ? profBonus
                                  : null,
                              color: Theme.of(context).intelligenceColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Investigation',
                              attributeName: 'Intelligence',
                              proficiency: skillProf.contains('investigation')
                                  ? profBonus
                                  : null,
                              color: Theme.of(context).intelligenceColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Nature',
                              attributeName: 'Intelligence',
                              proficiency: skillProf.contains('nature')
                                  ? profBonus
                                  : null,
                              color: Theme.of(context).intelligenceColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Religion',
                              attributeName: 'Intelligence',
                              proficiency: skillProf.contains('religion')
                                  ? profBonus
                                  : null,
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
                            Text('Wisdom',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                        color: Theme.of(context).wisdomColor,
                                        fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Skill(
                              skillName: 'Animal Handling',
                              attributeName: 'Wisdom',
                              proficiency: skillProf.contains('animal_handling')
                                  ? profBonus
                                  : null,
                              color: Theme.of(context).wisdomColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Insight',
                              attributeName: 'Wisdom',
                              proficiency: skillProf.contains('insight')
                                  ? profBonus
                                  : null,
                              color: Theme.of(context).wisdomColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Medicine',
                              attributeName: 'Wisdom',
                              proficiency: skillProf.contains('medicine')
                                  ? profBonus
                                  : null,
                              color: Theme.of(context).wisdomColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Perception',
                              attributeName: 'Wisdom',
                              proficiency: skillProf.contains('perception')
                                  ? profBonus
                                  : null,
                              color: Theme.of(context).wisdomColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Survival',
                              attributeName: 'Wisdom',
                              proficiency: skillProf.contains('survival')
                                  ? profBonus
                                  : null,
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
                            Text('Charisma',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(
                                        color: Theme.of(context).charismaColor,
                                        fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Skill(
                              skillName: 'Deception',
                              attributeName: 'Charisma',
                              proficiency: skillProf.contains('deception')
                                  ? profBonus
                                  : null,
                              color: Theme.of(context).charismaColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Intimidation',
                              attributeName: 'Charisma',
                              proficiency: skillProf.contains('intimidation')
                                  ? profBonus
                                  : null,
                              color: Theme.of(context).charismaColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Performance',
                              attributeName: 'Charisma',
                              proficiency: skillProf.contains('performance')
                                  ? profBonus
                                  : null,
                              color: Theme.of(context).charismaColor,
                              character: widget.character,
                            ),
                            Skill(
                              skillName: 'Persuasion',
                              attributeName: 'Charisma',
                              proficiency: skillProf.contains('persuasion')
                                  ? profBonus
                                  : null,
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
