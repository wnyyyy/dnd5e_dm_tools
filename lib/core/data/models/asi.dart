import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:equatable/equatable.dart';

class ASI extends Equatable {
  const ASI({
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
  });

  factory ASI.fromJson(Map<String, dynamic> json) {
    return ASI(
      strength: json[Attribute.strength.name] as int? ?? 10,
      dexterity: json[Attribute.dexterity.name] as int? ?? 10,
      constitution: json[Attribute.constitution.name] as int? ?? 10,
      intelligence: json[Attribute.intelligence.name] as int? ?? 10,
      wisdom: json[Attribute.wisdom.name] as int? ?? 10,
      charisma: json[Attribute.charisma.name] as int? ?? 10,
    );
  }

  int fromAttribute(Attribute attribute) {
    switch (attribute) {
      case Attribute.strength:
        return strength;
      case Attribute.dexterity:
        return dexterity;
      case Attribute.constitution:
        return constitution;
      case Attribute.intelligence:
        return intelligence;
      case Attribute.wisdom:
        return wisdom;
      case Attribute.charisma:
        return charisma;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      Attribute.strength.name: strength,
      Attribute.dexterity.name: dexterity,
      Attribute.constitution.name: constitution,
      Attribute.intelligence.name: intelligence,
      Attribute.wisdom.name: wisdom,
      Attribute.charisma.name: charisma,
    };
  }

  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;

  ASI copyFromName({required String name, required int value}) {
    return ASI(
      strength: name.toLowerCase() == Attribute.strength.name.toLowerCase()
          ? value
          : strength,
      dexterity: name.toLowerCase() == Attribute.dexterity.name.toLowerCase()
          ? value
          : dexterity,
      constitution:
          name.toLowerCase() == Attribute.constitution.name.toLowerCase()
          ? value
          : constitution,
      intelligence:
          name.toLowerCase() == Attribute.intelligence.name.toLowerCase()
          ? value
          : intelligence,
      wisdom: name.toLowerCase() == Attribute.wisdom.name.toLowerCase()
          ? value
          : wisdom,
      charisma: name.toLowerCase() == Attribute.charisma.name.toLowerCase()
          ? value
          : charisma,
    );
  }

  @override
  List<Object> get props => [
    strength,
    dexterity,
    constitution,
    intelligence,
    wisdom,
    charisma,
  ];
}
