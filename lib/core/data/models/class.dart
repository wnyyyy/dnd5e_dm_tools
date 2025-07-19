import 'package:dnd5e_dm_tools/core/data/models/class_table.dart';
import 'package:equatable/equatable.dart';

class Class extends Equatable {
  const Class({required this.slug, required this.name, required this.table});

  factory Class.fromJson(Map<String, dynamic> json, String documentId) {
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) {
      throw ArgumentError('Required field "name" is missing or empty');
    }
    final tableString = json['table'] as String?;
    if (tableString == null || tableString.isEmpty) {
      throw ArgumentError('Required field "table" is missing or empty');
    }
    final ClassTable table;
    try {
      table = ClassTable.fromString(tableString);
    } catch (e) {
      throw ArgumentError('Invalid table format: $e');
    }

    return Class(slug: documentId, name: name, table: table);
  }

  final String slug;
  final String name;
  final ClassTable table;

  Map<String, dynamic> toJson() {
    return {'name': name, 'table': table};
  }

  Class copyWith() {
    return Class(slug: slug, name: name, table: table);
  }

  @override
  List<Object> get props => [slug, name, table];

  @override
  String toString() => 'Class $slug(name: $name)';
}
