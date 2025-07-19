import 'package:equatable/equatable.dart';

class Item extends Equatable {
  const Item({required this.slug, required this.name});

  factory Item.fromJson(Map<String, dynamic> json, String documentId) {
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) {
      throw ArgumentError('Required field "name" is missing or empty');
    }

    return Item(slug: documentId, name: name);
  }

  final String slug;
  final String name;

  Map<String, dynamic> toJson() {
    return {'name': name};
  }

  Item copyWith() {
    return Item(slug: slug, name: name);
  }

  @override
  List<Object> get props => [slug, name];

  @override
  String toString() => 'Item $slug(name: $name)';
}
