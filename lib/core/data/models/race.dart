import 'package:equatable/equatable.dart';

class Race extends Equatable {
  const Race({required this.slug, required this.name, required this.traits});

  factory Race.fromJson(Map<String, dynamic> json, String documentId) {
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) {
      throw ArgumentError('Required field "name" is missing or empty');
    }
    final traits = json['traits'] as String? ?? '';

    return Race(slug: documentId, name: name, traits: traits);
  }

  final String slug;
  final String name;
  final String traits;

  Map<String, dynamic> toJson() {
    return {'name': name, 'traits': traits};
  }

  Race copyWith() {
    return Race(slug: slug, name: name, traits: traits);
  }

  @override
  List<Object> get props => [slug, name, traits];

  @override
  String toString() => 'Race $slug(name: $name)';
}
