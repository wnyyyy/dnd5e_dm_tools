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
    final lines = traits.split('\n').where((line) => line.isNotEmpty).toList();
    String currName = '';
    String currDesc = '';
    List<String> currEffectsDesc = [];
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith('**')) {
        if (currName.isNotEmpty) {
          features.add(
            Feat(
              name: currName,
              description: currDesc,
              slug: currName,
              effectsDesc: currEffectsDesc,
            ),
          );
          currEffectsDesc = [];
        }
        final parts = line.split('**');
        if (parts[1].endsWith('.')) {
          currName = parts[1].substring(0, parts[1].length - 1).trim();
          currDesc = parts.sublist(2).join('**').trim();
        }
      } else {
        if (line.startsWith('-')) {
          currEffectsDesc.add(line.substring(1).trim());
        } else {
          currDesc += '\n$line';
        }
      }
    }
    if (currName.isNotEmpty) {
      features.add(
        Feat(
          name: currName,
          description: currDesc,
          slug: currName,
          effectsDesc: currEffectsDesc,
        ),
      );
    }

    return features;
  }

  @override
  List<Object> get props => [slug, name, traits];

  @override
  String toString() => 'Race $slug(name: $name)';
}
