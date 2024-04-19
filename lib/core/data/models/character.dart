import 'package:dnd5e_dm_tools/core/data/models/race.dart';

class Character {
  final String name;
  final Race race;

  Character({
    required this.name,
    required this.race,
  });

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'race_slug': race.slug,
    };
  }

  static Character fromMap(
      Map<String, dynamic> character, Map<String, dynamic> race) {
    return Character(
      name: character['name'] as String,
      race: Race.fromMap(race),
    );
  }
}
