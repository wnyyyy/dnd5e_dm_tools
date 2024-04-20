import 'dart:convert';

import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';

class Character {
  final String name;
  final Race race;
  final int level;
  final List<Feat> feats;

  Character({
    required this.name,
    required this.race,
    required this.level,
    required this.feats,
  });

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'race_slug': race.slug,
      'level': level,
      'feats': jsonEncode(feats.map((e) => e.toMap()).toList()),
    };
  }

  static Character fromMap(
      Map<String, dynamic> character, Map<String, dynamic> race) {
    return Character(
      name: character['name'] as String,
      race: Race.fromMap(race),
      level: character['level'] as int,
      feats: List<Feat>.from(
          jsonDecode(character['feats'] as String).map((e) => Feat.fromMap(e))),
    );
  }
}
