import 'dart:convert';

import 'package:dnd5e_dm_tools/core/data/models/asi.dart';

class Race {
  final String slug;
  final String name;
  final String description;
  final List<ASI> asi;
  final int? speed;
  final String? languages;
  final String? vision;
  final String? traits;
  //final List<dynamic>? subraces;

  Race({
    required this.slug,
    required this.name,
    required this.description,
    required this.asi,
    this.speed,
    this.languages,
    this.vision,
    this.traits,
    //this.subraces,
  });

  static Race fromMap(Map<String, dynamic> c) {
    return Race(
      slug: c['slug'] as String,
      name: c['name'] as String,
      description: c['description'] as String,
      asi: jsonDecode(c['asi']) as List<ASI>,
      speed: c['speed'] as int?,
      languages: c['languages'] as String?,
      vision: c['vision'] as String?,
      traits: c['traits'] as String?,
      //subraces: c['subraces'] as List<dynamic>,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'slug': slug,
      'name': name,
      'description': description,
      'asi': jsonEncode(asi.map((e) => e.toMap()).toList()),
      'speed': speed,
      'languages': languages,
      'vision': vision,
      'traits': traits,
      //'subraces': subraces,
    };
  }
}
