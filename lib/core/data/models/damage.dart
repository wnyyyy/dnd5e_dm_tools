import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:equatable/equatable.dart';

class Damage extends Equatable {
  const Damage({required this.dice, required this.type});

  factory Damage.fromJson(Map<String, dynamic> json) {
    final dice = json['damage_dice'] as String? ?? '';
    if (dice.isEmpty) {
      throw ArgumentError('Required field "damage_dice" is missing or empty');
    }
    final typeMap =
        (json['damage_type'] as Map?)?.cast<String, dynamic>() ?? {};
    final typeIndex = typeMap['index'] as String? ?? '';
    if (typeIndex.isEmpty) {
      throw ArgumentError('Required field "damage_type" is missing or empty');
    }
    final type = DamageType.values.firstWhere(
      (e) => e.slug == typeIndex,
      orElse: () => DamageType.bludgeoning,
    );

    return Damage(dice: dice, type: type);
  }

  final String dice;
  final DamageType type;

  Map<String, dynamic> toJson() {
    return {
      'damage_dice': dice,
      'damage_type': {'index': type.slug, 'name': type.name},
    };
  }

  @override
  List<Object?> get props => [dice, type];
}
