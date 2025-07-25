import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:equatable/equatable.dart';

class Spell extends Equatable {
  const Spell({
    required this.slug,
    required this.name,
    required this.level,
    required this.castingTime,
    required this.concentration,
    required this.components,
    required this.desc,
    required this.duration,
    required this.higherLevel,
    required this.school,
    required this.range,
    required this.ritual,
  });

  factory Spell.fromJson(Map<String, dynamic> json, String documentId) {
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) {
      throw ArgumentError('Required field "name" is missing or empty');
    }
    final concentrationStr = json['concentration'] as String? ?? '';
    final ritualStr = json['ritual'] as String? ?? '';

    return Spell(
      slug: documentId,
      name: name,
      level: json['level_int'] as int? ?? 0,
      castingTime: json['casting_time'] as String? ?? '',
      concentration:
          concentrationStr.toLowerCase() == 'yes' ||
          concentrationStr.toLowerCase() == 'true',
      components: json['components'] as String? ?? '',
      desc: json['desc'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      higherLevel: json['higher_level'] as String? ?? '',
      school: SpellSchool.values.firstWhere(
        (e) =>
            e.name.toLowerCase() == (json['school'] as String?)?.toLowerCase(),
        orElse: () => SpellSchool.abjuration,
      ),
      range: json['range'] as String? ?? '',
      ritual:
          ritualStr.toLowerCase() == 'yes' || ritualStr.toLowerCase() == 'true',
    );
  }

  final String slug;
  final String name;
  final int level;
  final String castingTime;
  final bool concentration;
  final String components;
  final String desc;
  final String duration;
  final String higherLevel;
  final SpellSchool school;
  final String range;
  final bool ritual;

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'name': name,
      'level_int': level,
      'casting_time': castingTime,
      'concentration': concentration,
      'components': components,
      'desc': desc,
      'duration': duration,
      'higher_level': higherLevel,
      'school': school.name,
      'range': range,
      'ritual': ritual,
    };
  }

  String get fullDesc {
    return desc +
        (higherLevel.isNotEmpty ? '\n\n*At Higher Levels: $higherLevel*' : '');
  }

  Spell copyWith({
    String? slug,
    String? name,
    int? level,
    String? castingTime,
    bool? concentration,
    String? components,
    String? desc,
    String? duration,
    String? higherLevel,
    SpellSchool? school,
    String? range,
    bool? ritual,
  }) {
    return Spell(
      slug: slug ?? this.slug,
      name: name ?? this.name,
      level: level ?? this.level,
      castingTime: castingTime ?? this.castingTime,
      concentration: concentration ?? this.concentration,
      components: components ?? this.components,
      desc: desc ?? this.desc,
      duration: duration ?? this.duration,
      higherLevel: higherLevel ?? this.higherLevel,
      school: school ?? this.school,
      range: range ?? this.range,
      ritual: ritual ?? this.ritual,
    );
  }

  String get levelText {
    if (level == 0) {
      return 'Cantrip';
    } else if (level == 1) {
      return '1st-Level';
    } else {
      return '$level${level == 1
          ? 'st'
          : level == 2
          ? 'nd'
          : level == 3
          ? 'rd'
          : 'th'}-Level';
    }
  }

  String get levelTextPlural {
    if (level == 0) {
      return 'Cantrips';
    } else if (level == 1) {
      return '1st-level spells';
    } else {
      return '$level${level == 1
          ? 'st'
          : level == 2
          ? 'nd'
          : level == 3
          ? 'rd'
          : 'th'}-level spells';
    }
  }

  @override
  List<Object> get props => [
    slug,
    name,
    level,
    castingTime,
    concentration,
    components,
    desc,
    duration,
    higherLevel,
    school,
    range,
    ritual,
  ];
}
