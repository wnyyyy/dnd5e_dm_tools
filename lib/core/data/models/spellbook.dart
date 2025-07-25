import 'package:dnd5e_dm_tools/core/data/models/spell.dart';
import 'package:equatable/equatable.dart';

class Spellbook extends Equatable {
  const Spellbook({
    required this.knownSpells,
    required this.preparedSpells,
    required this.expendedSpellSlots,
  });

  factory Spellbook.fromJson(Map<String, dynamic> json) {
    return Spellbook(
      knownSpells: List<String>.from(json['known_spells'] as List? ?? []),
      preparedSpells: Map<String, bool>.from(
        json['prepared_spells'] as Map? ?? {},
      ),
      expendedSpellSlots: Map<int, int>.from(
        json['expended_spell_slots'] as Map? ?? {},
      ),
    );
  }

  final List<String> knownSpells;
  final Map<String, bool> preparedSpells;
  final Map<int, int> expendedSpellSlots;

  Map<String, dynamic> toJson() {
    return {
      'known_spells': knownSpells,
      'prepared_spells': preparedSpells,
      'expended_spell_slots': expendedSpellSlots,
    };
  }

  Spellbook useSlot(int level) {
    final updatedSlots = Map<int, int>.from(expendedSpellSlots);
    updatedSlots[level] = (updatedSlots[level] ?? 0) + 1;
    return copyWith(expendedSpellSlots: updatedSlots);
  }

  Spellbook resetSlots() {
    final updatedSlots = Map<int, int>.from(expendedSpellSlots);
    for (final level in updatedSlots.keys) {
      updatedSlots[level] = 0;
    }
    return copyWith(expendedSpellSlots: updatedSlots);
  }

  Spellbook copyWith({
    List<String>? knownSpells,
    Map<String, bool>? preparedSpells,
    Map<int, int>? expendedSpellSlots,
  }) {
    return Spellbook(
      knownSpells: knownSpells ?? this.knownSpells,
      preparedSpells: preparedSpells ?? this.preparedSpells,
      expendedSpellSlots: expendedSpellSlots ?? this.expendedSpellSlots,
    );
  }

  @override
  List<Object> get props => [knownSpells, preparedSpells, expendedSpellSlots];
}
