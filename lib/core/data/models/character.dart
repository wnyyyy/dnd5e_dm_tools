import 'package:equatable/equatable.dart';

class Character extends Equatable {
  const Character({
    required this.slug,
    required this.name,
    required this.imageUrl,
    required this.knownSpells,
    required this.classs,
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
    final classs = json['class'] as String?;
    if (classs == null || classs.isEmpty) {
      throw ArgumentError('Required field "class" is missing or empty');
    }
    return Character(
      slug: documentId,
      name: name,
      imageUrl: imageUrl,
      color: color,
      knownSpells: knownSpells,
      classs: classs,
    );
  }

  final String slug;
  final String name;
  final String imageUrl;
  final String? color;
  final List<String> knownSpells;
  final String classs;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image_url': imageUrl,
      'color': color,
      'known_spells': knownSpells,
      'class': classs,
    };
  }

  Character copyWith() {
    return Character(
      slug: slug,
      name: name,
      imageUrl: imageUrl,
      color: color,
      knownSpells: knownSpells,
      classs: classs,
    );
  }

  @override
  List<Object> get props => [slug, name, imageUrl, knownSpells, classs];

  @override
  String toString() =>
      'Character $slug(name: $name, class: $classs, color: $color)';
}
