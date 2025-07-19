import 'package:equatable/equatable.dart';

class Class extends Equatable {
  const Class({required this.slug, required this.name});

  factory Class.fromJson(Map<String, dynamic> json, String documentId) {
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) {
      throw ArgumentError('Required field "name" is missing or empty');
    }

    return Class(slug: documentId, name: name);
  }

  final String slug;
  final String name;

  Map<String, dynamic> toJson() {
    return {'name': name};
  }

  Class copyWith() {
    return Class(slug: slug, name: name);
  }

  @override
  List<Object> get props => [slug, name];

  @override
  String toString() => 'Class $slug(name: $name)';
}
