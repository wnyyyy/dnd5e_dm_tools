import 'package:equatable/equatable.dart';

class Feat extends Equatable {
  const Feat({
    required this.slug,
    required this.name,
    required this.description,
    required this.effectsDesc,
    this.prerequisite,
  });

  factory Feat.fromJson(Map<String, dynamic> json, String documentId) {
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) {
      throw ArgumentError('Required field "name" is missing or empty');
    }

    return Feat(
      slug: documentId,
      name: name,
      description: json['description'] as String? ?? '',
      effectsDesc:
          (json['effects_desc'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      prerequisite: json['prerequisite'] as String?,
    );
  }

  final String slug;
  final String name;
  final String description;
  final List<String> effectsDesc;
  final String? prerequisite;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'effects_desc': effectsDesc,
      'prerequisite': prerequisite,
    };
  }

  Feat copyWith() {
    return Feat(
      slug: slug,
      name: name,
      description: description,
      effectsDesc: effectsDesc,
      prerequisite: prerequisite,
    );
  }

  @override
  List<Object> get props => [
    slug,
    name,
    description,
    effectsDesc,
    prerequisite ?? '',
  ];

  @override
  String toString() =>
      'Feat $slug(name: $name, description: $description, effectsDesc: $effectsDesc, prerequisite: $prerequisite)';
}
