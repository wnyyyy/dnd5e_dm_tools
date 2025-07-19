import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:equatable/equatable.dart';

class Archetype extends Equatable {
  const Archetype({required this.slug, required this.name, required this.desc});

  factory Archetype.fromJson(Map<String, dynamic> json, String documentId) {
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) {
      throw ArgumentError('Required field "name" is missing or empty');
    }

    return Archetype(
      slug: documentId,
      name: name,
      desc: json['desc'] as String? ?? '',
    );
  }

  final String slug;
  final String name;
  final String desc;

  Map<String, dynamic> toJson() {
    return {'name': name, 'desc': desc};
  }

  Archetype copyWith() {
    return Archetype(slug: slug, name: name, desc: desc);
  }

  Map<String, dynamic> getFeatures(
    String desc, {
    int level = 20,
    List<Map<String, dynamic>> table = const [],
  }) {
    final Map<String, dynamic> features = <String, dynamic>{};
    List<String> lines = desc.split('\n');
    lines = lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    String currentFeatureKey = '';
    List<String> currentFeatureDescription = [];

    for (final line in lines) {
      if (line.startsWith('##### ')) {
        if (currentFeatureKey.isNotEmpty) {
          features[currentFeatureKey] = {
            'description': currentFeatureDescription.join('\n'),
          };
        }
        currentFeatureKey = line.substring(6).trim();
        currentFeatureDescription = [];
      } else {
        currentFeatureDescription.add(line.trim());
      }
    }

    if (currentFeatureKey.isNotEmpty) {
      features[currentFeatureKey] = {
        'description': currentFeatureDescription.join('\n'),
      };
    }

    if (table.isNotEmpty) {
      final Map<String, dynamic> filteredFeatures = <String, dynamic>{};
      for (final feature in features.keys) {
        for (final entry in table) {
          final int levelEntry = fromOrdinal(entry['Level'] as String? ?? '');
          if ((entry['Features'] ?? '').toString().toLowerCase().contains(
                feature.toLowerCase(),
              ) &&
              levelEntry <= level) {
            filteredFeatures[feature] = features[feature];
          }
        }
      }
      return filteredFeatures;
    }

    return features;
  }

  @override
  List<Object> get props => [slug, name, desc];

  @override
  String toString() => 'Archetype $slug(name: $name)';
}
