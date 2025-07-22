import 'package:dnd5e_dm_tools/core/data/models/asi.dart';
import 'package:dnd5e_dm_tools/core/data/models/backpack.dart';
import 'package:dnd5e_dm_tools/core/data/models/character_stats.dart';
import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
import 'package:dnd5e_dm_tools/core/data/models/proficiency.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:equatable/equatable.dart';

class Character extends Equatable {
  const Character({
    required this.slug,
    required this.name,
    required this.imageUrl,
    required this.knownSpells,
    required this.classs,
    required this.race,
    required this.level,
    required this.feats,
    required this.proficiency,
    required this.asi,
    required this.stats,
    required this.backpack,
    this.color,
    this.archetype,
  });

  factory Character.fromJson(Map<String, dynamic> json, String documentId) {
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) {
      throw ArgumentError('Required field "name" is missing or empty');
    }
    final classs = json['class'] as String?;
    if (classs == null || classs.isEmpty) {
      throw ArgumentError('Required field "class" is missing or empty');
    }
    final race = json['race'] as String?;
    if (race == null || race.isEmpty) {
      throw ArgumentError('Required field "race" is missing or empty');
    }

    final imageUrl = json['image_url'] as String? ?? '';
    final color = json['color'] as String?;
    final knownSpells =
        (json['known_spells'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];

    final feats =
        (json['feats'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as String?),
        ) ??
        <String, String>{};

    final proficiency = Proficiency.fromJson(
      json['proficiency'] as Map<String, dynamic>? ?? {},
    );

    final asi = ASI.fromJson(json['asi'] as Map<String, dynamic>? ?? {});

    final characterStats = CharacterStats.fromJson(
      json['character_stats'] as Map<String, dynamic>? ?? {},
      10 + getModifier(asi.dexterity),
    );

    final backpack = Backpack.fromJson(
      (json['backpack'] as Map<String, dynamic>?) ?? {},
    );

    return Character(
      slug: documentId,
      name: name,
      imageUrl: imageUrl,
      color: color,
      knownSpells: knownSpells,
      classs: classs,
      race: race,
      level: json['level'] as int? ?? 1,
      archetype: json['archetype'] as String?,
      feats: feats,
      proficiency: proficiency,
      asi: asi,
      stats: characterStats,
      backpack: backpack,
    );
  }

  List<Feat> getFeatList(List<Feat> allFeats) {
    final charFeats = <Feat>[];
    feats.forEach((key, value) {
      final feat = allFeats.firstWhere(
        (f) => f.slug == key,
        orElse: () => Feat(
          slug: key.toLowerCase().trim().replaceAll(' ', '_'),
          name: key,
          description: value ?? '',
          effectsDesc: const [],
        ),
      );
      charFeats.add(feat.copyWith(descOverride: value));
    });
    return charFeats;
  }

  final String slug;
  final String name;
  final String imageUrl;
  final String? color;
  final List<String> knownSpells;
  final String classs;
  final String race;
  final int level;
  final String? archetype;
  final Map<String, String?> feats;
  final Proficiency proficiency;
  final ASI asi;
  final CharacterStats stats;
  final Backpack backpack;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image_url': imageUrl,
      'color': color,
      'known_spells': knownSpells,
      'class': classs,
      'race': race,
      'level': level,
      'archetype': archetype,
      'feats': feats,
      'proficiency': proficiency.toJson(),
      'asi': asi.toJson(),
      'character_stats': stats.toJson(),
      'backpack': {},
    };
  }

  Character copyWith({
    int? level,
    Map<String, String?>? feats,
    Proficiency? proficiency,
    ASI? asi,
    CharacterStats? stats,
    Backpack? backpack,
  }) {
    return Character(
      slug: slug,
      name: name,
      imageUrl: imageUrl,
      color: color,
      knownSpells: knownSpells,
      classs: classs,
      race: race,
      level: level ?? this.level,
      archetype: archetype,
      feats: feats ?? this.feats,
      proficiency: proficiency ?? this.proficiency,
      asi: asi ?? this.asi,
      stats: stats ?? this.stats,
      backpack: backpack ?? this.backpack,
    );
  }

  @override
  List<Object> get props => [
    slug,
    name,
    imageUrl,
    knownSpells,
    classs,
    level,
    race,
    feats,
    color ?? '',
    archetype ?? '',
    proficiency,
    asi,
    stats,
    backpack,
  ];

  @override
  String toString() =>
      'Character $slug(name: $name, class: $classs, color: $color, level: $level, knownSpells: $knownSpells)';
}
