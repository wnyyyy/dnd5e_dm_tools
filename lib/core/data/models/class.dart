import 'package:dnd5e_dm_tools/core/data/models/archetype.dart';
import 'package:dnd5e_dm_tools/core/data/models/class_table.dart';
import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
import 'package:dnd5e_dm_tools/core/data/models/proficiency.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:equatable/equatable.dart';

class Class extends Equatable {
  const Class({
    required this.slug,
    required this.name,
    required this.table,
    required this.hitDice,
    required this.profSavingThrows,
    required this.profWeapons,
    required this.profTools,
    required this.profArmor,
    required this.profSkills,
    required this.desc,
    this.spellCastingAbility,
    this.archetypes = const [],
  });

  factory Class.fromJson(Map<String, dynamic> json, String documentId) {
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) {
      throw ArgumentError('Required field "name" is missing or empty');
    }
    final tableString = json['table'] as String?;
    if (tableString == null || tableString.isEmpty) {
      throw ArgumentError('Required field "table" is missing or empty');
    }
    final ClassTable table;
    try {
      table = ClassTable.fromString(tableString);
    } catch (e) {
      throw ArgumentError('Invalid table format: $e');
    }
    final hitDice = json['hit_dice'] as String?;
    if (hitDice == null || hitDice.isEmpty) {
      throw ArgumentError('Required field "hit_dice" is missing or empty');
    }
    final profSavingThrows = json['prof_saving_throws'] as String? ?? '';
    final profWeapons = json['prof_weapons'] as String? ?? '';
    final profTools = json['prof_tools'] as String? ?? '';
    final profArmor = json['prof_armor'] as String? ?? '';
    final profSkills = json['prof_skills'] as String? ?? '';
    Attribute? spellCastingAbility;
    try {
      spellCastingAbility = Attribute.values.firstWhere(
        (e) => e.name == (json['spellcasting_ability'] as String?),
      );
    } catch (e) {
      spellCastingAbility = null;
    }

    final desc = json['desc'] as String? ?? '';

    final List<Archetype> archetypes;
    try {
      final List<Map<String, dynamic>> archetypesJson =
          (json['archetypes'] as List<dynamic>?)
              ?.map((e) => (e as Map).cast<String, dynamic>())
              .toList() ??
          [];
      archetypes = archetypesJson
          .map((e) => Archetype.fromJson(e, e['slug'] as String))
          .toList();
    } catch (e) {
      throw ArgumentError('Invalid archetypes format: $e');
    }

    return Class(
      slug: documentId,
      name: name,
      table: table,
      archetypes: archetypes,
      hitDice: hitDice,
      profSavingThrows: profSavingThrows,
      profWeapons: profWeapons,
      profTools: profTools,
      profArmor: profArmor,
      profSkills: profSkills,
      spellCastingAbility: spellCastingAbility,
      desc: desc,
    );
  }

  final String slug;
  final String name;
  final String desc;
  final ClassTable table;
  final List<Archetype> archetypes;
  final String hitDice;
  final String profSavingThrows;
  final String profWeapons;
  final String profTools;
  final String profArmor;
  final String profSkills;
  final Attribute? spellCastingAbility;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'table': table.toString(),
      'desc': desc,
      'archetypes': archetypes.map((e) => e.toJson()).toList(),
      'hit_dice': hitDice,
      'prof_saving_throws': profSavingThrows,
      'prof_weapons': profWeapons,
      'prof_tools': profTools,
      'prof_armor': profArmor,
      'prof_skills': profSkills,
      'spellcasting_ability': spellCastingAbility?.name,
    };
  }

  Class copyWith() {
    return Class(
      slug: slug,
      name: name,
      table: table,
      desc: desc,
      archetypes: archetypes,
      hitDice: hitDice,
      profSavingThrows: profSavingThrows,
      profWeapons: profWeapons,
      profTools: profTools,
      profArmor: profArmor,
      profSkills: profSkills,
      spellCastingAbility: spellCastingAbility,
    );
  }

  Proficiency get proficiency {
    return Proficiency(
      languages: profSkills,
      weapons: profWeapons,
      armor: profArmor,
      tools: profTools,
      savingThrows: profSavingThrows
          .split(',')
          .map(
            (e) => Attribute.values.firstWhere(
              (attr) => attr.name.toLowerCase() == e.trim().toLowerCase(),
            ),
          )
          .toList(),
      skills: const {},
    );
  }

  Map<int, int> getSpellSlotsForLevel(int level) {
    return table.getSpellSlotsForLevel(level);
  }

  List<Feat> getFeatures({int level = 20}) {
    List<String> lines = desc.split('\n');
    lines = lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final List<Feat> featList = buildFeatList(lines);

    final featNamesLeveled = [];
    for (int i = 1; i <= level; i++) {
      final levelEntry = table.levelData[i];
      if (levelEntry != null) {
        featNamesLeveled.addAll(levelEntry.features);
      }
    }

    final featsLeveled = featList
        .where(
          (feat) =>
              feat.name.isNotEmpty && featNamesLeveled.contains(feat.name),
        )
        .toList();

    return featsLeveled;
  }

  @override
  List<Object> get props => [
    slug,
    name,
    table,
    archetypes,
    hitDice,
    profSavingThrows,
    profWeapons,
    profTools,
    profArmor,
    profSkills,
  ];

  @override
  String toString() => 'Class $slug(name: $name)';
}
