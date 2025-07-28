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
      description: json['desc'] as String? ?? '',
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

  String get fullDescription {
    final StringBuffer builder = StringBuffer();
    builder.write(description);
    if (effectsDesc.isNotEmpty) {
      builder.writeln();
    }
    for (final effect in effectsDesc) {
      if (effect.isNotEmpty) {
        builder.writeln();
        builder.writeln('- $effect');
      }
    }
    return builder.toString().trim();
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'name': name,
      'desc': description,
      'effects_desc': effectsDesc,
      'prerequisite': prerequisite,
    };
  }

  Feat copyWith({
    String? name,
    String? description,
    List<String>? effectsDesc,
  }) {
    return Feat(
      slug: slug,
      name: name ?? this.name,
      description: description ?? this.description,
      effectsDesc: effectsDesc ?? this.effectsDesc,
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

  static (String, List<String>) buildFromDescription(String description) {
    final lines = description.split('\n').toList();
    final effectsDesc = <String>[];
    final StringBuffer currDesc = StringBuffer();
    bool isDesc = true;
    for (final line in lines) {
      if (line.startsWith('-')) {
        effectsDesc.add(line.substring(1).trim());
        isDesc = false;
      }
      if (isDesc) {
        currDesc.writeln(line);
      } else {
        if (!line.startsWith('-')) {
          final lineAux = line.trim();
          effectsDesc.last += '\n$lineAux';
        }
      }
    }
    return (currDesc.toString(), effectsDesc);
  }
}
