import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:equatable/equatable.dart';

class Proficiency extends Equatable {
  const Proficiency({
    required this.languages,
    required this.weapons,
    required this.armor,
    required this.tools,
    required this.savingThrows,
    required this.skills,
  });

  factory Proficiency.fromJson(Map<String, dynamic> json) {
    final languages = json['languages'] as String? ?? '';
    final weapons = json['weapons'] as String? ?? '';
    final armor = json['armor'] as String? ?? '';
    final tools = json['tools'] as String? ?? '';
    final savingThrows =
        (json['saving_throws'] as List<dynamic>?)
            ?.map(
              (e) => Attribute.values.firstWhere(
                (a) => a.name.toLowerCase() == e.toString().toLowerCase(),
              ),
            )
            .toList() ??
        [];
    final skills =
        (json['skills'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(
            Skill.values.firstWhere(
              (e) => e.name.toLowerCase() == key.toLowerCase(),
            ),
            ProficiencyLevel.values.firstWhere(
              (e) => e.toString() == 'ProficiencyLevel.$value',
            ),
          ),
        ) ??
        {};

    return Proficiency(
      languages: languages,
      weapons: weapons,
      armor: armor,
      tools: tools,
      savingThrows: savingThrows,
      skills: skills,
    );
  }

  final String languages;
  final String weapons;
  final String armor;
  final String tools;
  final List<Attribute> savingThrows;
  final Map<Skill, ProficiencyLevel> skills;

  Map<String, dynamic> toJson() {
    return {
      'languages': languages,
      'weapons': weapons,
      'armor': armor,
      'tools': tools,
      'saving_throws': savingThrows.map((e) => e.name.toLowerCase()).toList(),
      'skills': skills.map(
        (key, value) =>
            MapEntry(key.name.toLowerCase(), value.name.toLowerCase()),
      ),
    };
  }

  Proficiency copyWith({
    String? languages,
    String? weapons,
    String? armor,
    String? tools,
    List<Attribute>? savingThrows,
    Map<Skill, ProficiencyLevel>? skills,
  }) {
    return Proficiency(
      languages: languages ?? this.languages,
      weapons: weapons ?? this.weapons,
      armor: armor ?? this.armor,
      tools: tools ?? this.tools,
      savingThrows: List<Attribute>.from(savingThrows ?? this.savingThrows),
      skills: Map<Skill, ProficiencyLevel>.from(skills ?? this.skills),
    );
  }

  @override
  List<Object> get props => [
    languages,
    weapons,
    armor,
    tools,
    savingThrows,
    skills,
  ];
}
