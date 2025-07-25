import 'package:dnd5e_dm_tools/core/data/models/action.dart';
import 'package:dnd5e_dm_tools/core/data/models/asi.dart';
import 'package:dnd5e_dm_tools/core/data/models/backpack.dart';
import 'package:dnd5e_dm_tools/core/data/models/character_stats.dart';
import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
import 'package:dnd5e_dm_tools/core/data/models/proficiency.dart';
import 'package:dnd5e_dm_tools/core/data/models/spellbook.dart';
import 'package:equatable/equatable.dart';

class Character extends Equatable {
  const Character({
    required this.slug,
    required this.name,
    required this.imageUrl,
    required this.classs,
    required this.race,
    required this.level,
    required this.feats,
    required this.proficiency,
    required this.asi,
    required this.stats,
    required this.backpack,
    required this.spellbook,
    required this.actions,
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
      Map<String, dynamic>.from(json['character_stats'] as Map? ?? {}),
      asi: asi,
      level: json['level'] as int? ?? 1,
      proficiency: proficiency,
    );

    final backpack = Backpack.fromJson(
      (json['backpack'] as Map<String, dynamic>?) ?? {},
    );

    final spellbook = Spellbook.fromJson(
      (json['spellbook'] as Map<String, dynamic>?) ?? {},
    );

    final actions =
        (json['actions'] as List<dynamic>?)
            ?.map(
              (e) =>
                  Action.fromJson(Map<String, dynamic>.from(e as Map? ?? {})),
            )
            .toList() ??
        [];

    return Character(
      slug: documentId,
      name: name,
      imageUrl: imageUrl,
      color: color,
      classs: classs,
      race: race,
      level: json['level'] as int? ?? 1,
      archetype: json['archetype'] as String?,
      feats: feats,
      proficiency: proficiency,
      asi: asi,
      stats: characterStats,
      backpack: backpack,
      spellbook: spellbook,
      actions: actions,
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
  final String classs;
  final String race;
  final int level;
  final String? archetype;
  final Map<String, String?> feats;
  final Proficiency proficiency;
  final ASI asi;
  final CharacterStats stats;
  final Backpack backpack;
  final Spellbook spellbook;
  final List<Action> actions;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image_url': imageUrl,
      'color': color,
      'class': classs,
      'race': race,
      'level': level,
      'archetype': archetype,
      'feats': feats,
      'proficiency': proficiency.toJson(),
      'asi': asi.toJson(),
      'character_stats': stats.toJson(),
      'backpack': backpack.toJson(),
      'spellbook': spellbook.toJson(),
      'actions': actions.map((e) => e.toJson()).toList(),
    };
  }

  Character copyWith({
    int? level,
    Map<String, String?>? feats,
    Proficiency? proficiency,
    ASI? asi,
    CharacterStats? stats,
    Backpack? backpack,
    Spellbook? spellbook,
    List<Action>? actions,
  }) {
    return Character(
      slug: slug,
      name: name,
      imageUrl: imageUrl,
      color: color,
      classs: classs,
      race: race,
      level: level ?? this.level,
      archetype: archetype,
      feats: feats ?? this.feats,
      proficiency: proficiency ?? this.proficiency,
      asi: asi ?? this.asi,
      stats: stats ?? this.stats,
      backpack: backpack ?? this.backpack,
      spellbook: spellbook ?? this.spellbook,
      actions: actions ?? this.actions,
    );
  }

  @override
  List<Object> get props => [
    slug,
    name,
    imageUrl,
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
    spellbook,
    actions,
  ];

  @override
  String toString() =>
      'Character $slug(name: $name, class: $classs, color: $color, level: $level)';
}
