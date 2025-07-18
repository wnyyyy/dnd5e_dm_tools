import 'package:equatable/equatable.dart';

class Character extends Equatable {
  const Character({
    required this.slug,
    required this.name,
    required this.imageUrl,
    required this.knownSpells,
    this.color,
  });

  factory Character.fromJson(Map<String, dynamic> json, String documentId) {
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) {
      throw ArgumentError('Required field "name" is missing or empty');
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
    );
  }

  final String slug;
  final String name;
  final String imageUrl;
  final String? color;
  final List<String> knownSpells;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image_url': imageUrl,
      'color': color,
      'known_spells': knownSpells,
    };
  }

  Character copyWith() {
    return Character(
      slug: slug,
      name: name,
      imageUrl: imageUrl,
      color: color,
      knownSpells: knownSpells,
    );
  }

  @override
  List<Object> get props => [slug, name, imageUrl, knownSpells];

  @override
  String toString() => 'Character $slug(name: $name)';
}
