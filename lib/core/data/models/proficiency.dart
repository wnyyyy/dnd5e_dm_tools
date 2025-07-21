import 'package:equatable/equatable.dart';

class Proficiency extends Equatable {
  const Proficiency({
    required this.languages,
    required this.weapons,
    required this.armor,
    required this.tools,
  });

  factory Proficiency.fromJson(Map<String, dynamic> json) {
    final languages = json['languages'] as String? ?? '';
    final weapons = json['weapons'] as String? ?? '';
    final armor = json['armor'] as String? ?? '';
    final tools = json['tools'] as String? ?? '';

    return Proficiency(
      languages: languages,
      weapons: weapons,
      armor: armor,
      tools: tools,
    );
  }

  final String languages;
  final String weapons;
  final String armor;
  final String tools;

  Map<String, dynamic> toJson() {
    return {
      'languages': languages,
      'weapons': weapons,
      'armor': armor,
      'tools': tools,
    };
  }

  Proficiency copyWith() {
    return Proficiency(
      languages: languages,
      weapons: weapons,
      armor: armor,
      tools: tools,
    );
  }

  @override
  List<Object> get props => [languages, weapons, armor, tools];
}
