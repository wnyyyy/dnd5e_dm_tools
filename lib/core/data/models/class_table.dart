import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:equatable/equatable.dart';

class ClassTable extends Equatable {
  const ClassTable({required this.levelData});
  factory ClassTable.fromString(String tableString) {
    final List<String> rows = tableString.trim().split('\n');
    if (rows.length != 22) {
      throw ArgumentError(
        'Invalid table format: Expected 22 rows, got ${rows.length}',
      );
    }

    final List<String> headers = rows[0]
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final Map<int, ClassTableRow> levelData = {};

    for (var i = 2; i < rows.length; i++) {
      final List<String> rowValues = rows[i]
          .split('|')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (rowValues.length != headers.length) {
        throw FormatException('Row $i does not match header length');
      }

      final Map<String, dynamic> rowMap = {};
      for (var j = 0; j < headers.length; j++) {
        rowMap[headers[j]] = rowValues[j];
      }

      final classTableRow = ClassTableRow.fromMap(rowMap, i - 2);
      levelData[i - 1] = classTableRow;
    }

    return ClassTable(levelData: levelData);
  }

  final Map<int, ClassTableRow> levelData;

  Map<int, int> getSpellSlotsForLevel(int level) {
    final row = levelData[level];
    if (row != null) {
      return row.spellSlots ?? {};
    }
    return {};
  }

  @override
  List<Object?> get props => [levelData];
}

class ClassTableRow extends Equatable {
  const ClassTableRow({
    required this.level,
    required this.proficiencyBonus,
    required this.features,
    this.spellSlots,
    this.cantripsKnown,
    this.spellsKnown,
    this.classSpecificFeatures,
  });
  factory ClassTableRow.fromMap(Map<String, dynamic> map, int level) {
    final int proficiencyBonus;
    try {
      proficiencyBonus = int.parse(map.entries.elementAt(1).value.toString());
    } catch (e) {
      throw ArgumentError(
        'Invalid proficiency bonus format: $e at level $level',
      );
    }

    final List<String> features = [];
    if (map['Features'] != null) {
      features.addAll(
        map['Features'].toString().split(',').map((e) => e.trim()),
      );
    }

    final Map<int, int> spellSlots = {};
    for (var i = 1; i <= 9; i++) {
      final key = getOrdinal(i);
      if (map.containsKey(key)) {
        final value = int.tryParse(map[key].toString()) ?? 0;
        if (value > 0) spellSlots[i] = value;
      }
    }

    int? cantripsKnown;
    if (map.containsKey('Cantrips Known')) {
      cantripsKnown = int.tryParse(map['Cantrips Known'].toString());
    }
    int? spellsKnown;
    if (map.containsKey('Spells Known')) {
      spellsKnown = int.tryParse(map['Spells Known'].toString());
    }

    const standardFields = [
      'lv.',
      'level',
      'proficiency bonus',
      'pb',
      'features',
      'cantrips known',
      'cantrips',
      'spells known',
      'spells',
      'slot level',
      '1st',
      '2nd',
      '3rd',
      '4th',
      '5th',
      '6th',
      '7th',
      '8th',
      '9th',
    ];

    final Map<String, dynamic> classSpecific = map.entries
        .where((e) => !standardFields.contains(e.key.toLowerCase()))
        .fold<Map<String, dynamic>>({}, (acc, e) {
          acc[e.key] = e.value;
          return acc;
        });

    return ClassTableRow(
      level: level,
      proficiencyBonus: proficiencyBonus,
      features: features,
      classSpecificFeatures: classSpecific,
      spellSlots: spellSlots.isNotEmpty ? spellSlots : null,
      cantripsKnown: cantripsKnown,
      spellsKnown: spellsKnown,
    );
  }

  final int level;
  final int proficiencyBonus;
  final List<String> features;
  final Map<int, int>? spellSlots;
  final int? cantripsKnown;
  final int? spellsKnown;
  final Map<String, dynamic>? classSpecificFeatures;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'Level': level,
      'Proficiency Bonus': proficiencyBonus,
      'Features': features.join(', '),
    };

    if (cantripsKnown != null) {
      map['Cantrips Known'] = cantripsKnown;
    }

    if (spellsKnown != null) {
      map['Spells Known'] = spellsKnown;
    }

    if (classSpecificFeatures != null) {
      map.addAll(classSpecificFeatures!);
    }

    return map;
  }

  @override
  String toString() {
    final headers = [
      'Level',
      'Proficiency Bonus',
      'Features',
      if (cantripsKnown != null) 'Cantrips Known',
      if (spellsKnown != null) 'Spells Known',
      ...classSpecificFeatures?.keys ?? [],
    ];
    final List<List<String>> rows = [];
    for (var i = 0; i < 20; i++) {
      final row = <String>[
        level.toString(),
        proficiencyBonus.toString(),
        features.join(', '),
        if (cantripsKnown != null) cantripsKnown.toString(),
        if (spellsKnown != null) spellsKnown.toString(),
        ...classSpecificFeatures?.values.map((e) => e.toString()) ?? [],
      ];
      rows.add(row);
    }
    final buffer = StringBuffer();
    buffer.writeln(headers.join(' | '));
    buffer.writeln('...');
    for (final row in rows) {
      buffer.writeln(row.join(' | '));
    }
    return buffer.toString();
  }

  @override
  List<Object?> get props => [
    level,
    proficiencyBonus,
    features,
    spellSlots,
    cantripsKnown,
    spellsKnown,
    classSpecificFeatures,
  ];
}
