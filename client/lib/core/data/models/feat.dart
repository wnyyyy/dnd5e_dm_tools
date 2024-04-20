import 'dart:convert';

class Feat {
  final String slug;
  final String name;
  final String description;
  final String prerequisite;
  final List<String> effectsDesc;
  final String documentTitle;

  Feat({
    required this.slug,
    required this.name,
    required this.description,
    required this.prerequisite,
    required this.effectsDesc,
    required this.documentTitle,
  });

  static Feat fromMap(Map<String, dynamic> c) {
    return Feat(
      slug: c['slug'] as String,
      name: c['name'] as String,
      description: c['description'] as String,
      prerequisite: c['prerequisite'] as String? ?? '*N/A*',
      effectsDesc: List<String>.from(c['effects_desc']),
      documentTitle: c['document_title'] as String? ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'slug': slug,
      'name': name,
      'description': description,
      'prerequisite': prerequisite,
      'effects_desc': jsonEncode(effectsDesc),
      'document_title': documentTitle,
    };
  }
}
