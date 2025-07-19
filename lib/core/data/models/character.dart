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
        (json['known_spells'] as List<String>?)?.map((e) => e).toList() ?? [];

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
    );
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
    };
  }

  Character copyWith({int? level}) {
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
    color ?? '',
    archetype ?? '',
  ];

  @override
  String toString() =>
      'Character $slug(name: $name, class: $classs, color: $color, level: $level, knownSpells: $knownSpells)';
}
