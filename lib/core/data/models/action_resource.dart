import 'package:equatable/equatable.dart';

class ActionResource extends Equatable {
  const ActionResource({
    required this.name,
    required this.formula,
    required this.shortRest,
    required this.longRest,
  });

  factory ActionResource.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) {
      throw ArgumentError('Required field "name" is missing or empty');
    }
    final formula = json['formula'] as String? ?? '';
    final shortRest = json['short_rest'] as String? ?? '';
    final longRest = json['long_rest'] as String? ?? 'all';

    return ActionResource(
      name: name,
      formula: formula,
      shortRest: shortRest,
      longRest: longRest,
    );
  }

  final String name;
  final String formula;
  final String shortRest;
  final String longRest;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'formula': formula,
      'short_rest': shortRest,
      'long_rest': longRest,
    };
  }

  ActionResource copyWith(
    String? name,
    String? formula,
    String? shortRest,
    String? longRest,
  ) {
    return ActionResource(
      name: name ?? this.name,
      formula: formula ?? this.formula,
      shortRest: shortRest ?? this.shortRest,
      longRest: longRest ?? this.longRest,
    );
  }

  @override
  List<Object> get props => [name, formula, shortRest, longRest];

  @override
  String toString() =>
      'ActionResource $name(formula: $formula, shortRest: $shortRest, longRest: $longRest)';
}
