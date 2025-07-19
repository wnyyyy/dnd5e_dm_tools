import 'package:equatable/equatable.dart';

class SpellList extends Equatable {
  const SpellList({
    required this.slug,
    required this.name,
    required this.spells,
  });

  factory SpellList.fromJson(Map<String, dynamic> json, String documentId) {
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) {
      throw ArgumentError('Required field "name" is missing or empty');
    }

    return SpellList(
      slug: documentId,
      name: name,
      spells: json['spells'] as List<String>? ?? [],
    );
  }

  final String slug;
  final String name;
  final List<String> spells;

  Map<String, dynamic> toJson() {
    return {'name': name, 'spells': spells};
  }

  SpellList copyWith() {
    return SpellList(slug: slug, name: name, spells: List.from(spells));
  }

  @override
  List<Object> get props => [slug, name, spells];

  @override
  String toString() => 'SpellList $slug(name: $name, spells: $spells)';
}
