import 'package:equatable/equatable.dart';

class Condition extends Equatable {
  const Condition({
    required this.slug,
    required this.name,
    required this.description,
  });

  factory Condition.fromJson(Map<String, dynamic> json, String documentId) {
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) {
      throw ArgumentError('Required field "name" is missing or empty');
    }

    return Condition(
      slug: documentId,
      name: name,
      description: json['description'] as String? ?? '',
    );
  }

  final String slug;
  final String name;
  final String description;

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }

  Condition copyWith() {
    return Condition(slug: slug, name: name, description: description);
  }

  @override
  List<Object> get props => [slug, name, description];

  @override
  String toString() =>
      'Condition $slug(name: $name, description: $description)';
}
