import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
import 'package:equatable/equatable.dart';

class Race extends Equatable {
  const Race({required this.slug, required this.name, required this.traits});

  factory Race.fromJson(Map<String, dynamic> json, String documentId) {
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) {
      throw ArgumentError('Required field "name" is missing or empty');
    }
    final traits = json['traits'] as String? ?? '';

    return Race(slug: documentId, name: name, traits: traits);
  }

  final String slug;
  final String name;
  final String traits;

  Map<String, dynamic> toJson() {
    return {'name': name, 'traits': traits};
  }

  Race copyWith() {
    return Race(slug: slug, name: name, traits: traits);
  }

  List<Feat> getRacialFeatures() {
    final features = <Feat>[];
    final rawFeatures = traits.split('**');

    for (var i = 1; i < rawFeatures.length; i += 2) {
      var name = rawFeatures[i].trim();
      final description = (i + 1 < rawFeatures.length)
          ? rawFeatures[i + 1].trim()
          : '';

      if (name.endsWith('.')) {
        name = name.substring(0, name.length - 1);
      }

      if (name.isNotEmpty && description.isNotEmpty) {
        features.add(
          Feat(
            name: name,
            description: description,
            slug: name.trim().replaceAll(' ', '_'),
            effectsDesc: const [],
          ),
        );
      }
    }

    return features;
  }

  @override
  List<Object> get props => [slug, name, traits];

  @override
  String toString() => 'Race $slug(name: $name)';
}
