import 'package:equatable/equatable.dart';

class Race extends Equatable {
  const Race({required this.slug, required this.name});

  factory Race.fromJson(Map<String, dynamic> json, String documentId) {
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) {
      throw ArgumentError('Required field "name" is missing or empty');
    }

    return Race(slug: documentId, name: name);
  }

  final String slug;
  final String name;

  Map<String, dynamic> toJson() {
    return {'name': name};
  }

  Race copyWith() {
    return Race(slug: slug, name: name);
  }

  @override
  List<Object> get props => [slug, name];

  @override
  String toString() => 'Race $slug(name: $name)';
}
