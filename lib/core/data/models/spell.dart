import 'package:equatable/equatable.dart';

class Spell extends Equatable {
  const Spell({required this.slug, required this.name});

  factory Spell.fromJson(Map<String, dynamic> json, String documentId) {
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) {
      throw ArgumentError('Required field "name" is missing or empty');
    }

    return Spell(slug: documentId, name: name);
  }

  final String slug;
  final String name;

  Map<String, dynamic> toJson() {
    return {'name': name};
  }

  Spell copyWith() {
    return Spell(slug: slug, name: name);
  }

  @override
  List<Object> get props => [slug, name];

  @override
  String toString() => 'Spell $slug(name: $name)';
}
