import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
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

  List<Feat> getFeatures() {
    List<String> lines = desc.split('\n');
    lines = lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final List<Feat> featList = buildFeatList(lines);

    return featList;
  }

  @override
  List<Object> get props => [slug, name, desc];

  @override
  String toString() => 'Archetype $slug(name: $name)';
}
