import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/maki_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:petitparser/petitparser.dart';
import 'package:shared_preferences/shared_preferences.dart';

int getModifier(int value) {
  return (value - 10) ~/ 2;
}

String getAttributeFromPrefix(String prefix) {
  switch (prefix.toLowerCase()) {
    case 'str':
      return 'strength';
    case 'dex':
      return 'dexterity';
    case 'con':
      return 'constitution';
    case 'int':
      return 'intelligence';
    case 'wis':
      return 'wisdom';
    case 'cha':
      return 'charisma';
    default:
      return '';
  }
}

int getProfBonus(int level) {
  return ((level - 1) ~/ 4) + 2;
}

String getOrdinal(int number) {
  final int lastDigit = number % 10;
  final int lastTwoDigits = number % 100;

  if ((lastTwoDigits >= 11) && (lastTwoDigits <= 13)) {
    return '${number}th';
  }

  switch (lastDigit) {
    case 1:
      return '${number}st';
    case 2:
      return '${number}nd';
    case 3:
      return '${number}rd';
    default:
      return '${number}th';
  }
}

int fromOrdinal(String ordinal) {
  return int.tryParse(ordinal.replaceAll(RegExp('[a-zA-Z]'), '')) ?? 0;
}

Map<String, dynamic> getClassFeatures(
  String desc, {
  int level = 20,
  List<Map<String, dynamic>> table = const [],
}) {
  final Map<String, dynamic> features = <String, dynamic>{};
  List<String> lines = desc.split('\n');
  lines = lines
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  String currentFeatureKey = '';
  String currentSubFeatureKey = '';
  List<String> currentFeatureDescription = [];
  List<String> currentSubFeatureDescription = [];
  Map<String, dynamic> currentFeature = {};

  for (final line in lines) {
    if (line.startsWith('### ')) {
      currentFeature =
          features[currentFeatureKey] as Map<String, dynamic>? ?? {};
      if (currentFeatureKey.isNotEmpty) {
        if (currentSubFeatureKey.isNotEmpty) {
          currentFeature[currentSubFeatureKey] =
              currentSubFeatureDescription.join('\n');
          currentSubFeatureKey = '';
          currentSubFeatureDescription = [];
        }
        currentFeature['description'] = currentFeatureDescription.join('\n');
      }
      currentFeatureKey = line.substring(4).trim();
      currentFeatureDescription = [];
    } else if (line.startsWith('#### ')) {
      if (currentSubFeatureKey.isNotEmpty) {
        currentFeature[currentSubFeatureKey] =
            currentSubFeatureDescription.join('\n');
      }
      currentSubFeatureKey = line.substring(5).trim();
      currentSubFeatureDescription = [];
    } else {
      if (currentSubFeatureKey.isNotEmpty) {
        currentSubFeatureDescription.add(line.trim());
      } else {
        currentFeatureDescription.add(line.trim());
      }
    }
  }

  if (currentFeatureKey.isNotEmpty) {
    if (currentSubFeatureKey.isNotEmpty) {
      currentFeature[currentSubFeatureKey] =
          currentSubFeatureDescription.join('\n');
    }
    currentFeature['description'] = currentFeatureDescription.join('\n');
  }

  if (table.isNotEmpty) {
    final Map<String, dynamic> filteredFeatures = <String, dynamic>{};
    for (final feature in features.keys) {
      for (final entry in table) {
        final int levelEntry = fromOrdinal(entry['Level'] as String);
        if ((entry['Features'] ?? '')
                .toString()
                .toLowerCase()
                .contains(feature.toLowerCase()) &&
            levelEntry <= level) {
          filteredFeatures[feature] = features[feature];
        }
      }
    }
    return filteredFeatures;
  }

  return features;
}

Map<String, dynamic> getRacialFeatures(String desc) {
  final features = <String, dynamic>{};
  final rawFeatures = desc.split('***');

  for (var i = 1; i < rawFeatures.length; i += 2) {
    var name = rawFeatures[i].trim();
    final description =
        (i + 1 < rawFeatures.length) ? rawFeatures[i + 1].trim() : '';

    if (name.endsWith('.')) {
      name = name.substring(0, name.length - 1);
    }

    if (name.isNotEmpty && description.isNotEmpty) {
      features[name] = description;
    }
  }

  return features;
}

Map<String, dynamic> getArchetypeFeatures(
  String desc, {
  int level = 20,
  List<Map<String, dynamic>> table = const [],
}) {
  final Map<String, dynamic> features = <String, dynamic>{};
  List<String> lines = desc.split('\n');
  lines = lines
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  String currentFeatureKey = '';
  List<String> currentFeatureDescription = [];

  for (final line in lines) {
    if (line.startsWith('##### ')) {
      if (currentFeatureKey.isNotEmpty) {
        features[currentFeatureKey] = {
          'description': currentFeatureDescription.join('\n'),
        };
      }
      currentFeatureKey = line.substring(6).trim();
      currentFeatureDescription = [];
    } else {
      currentFeatureDescription.add(line.trim());
    }
  }

  if (currentFeatureKey.isNotEmpty) {
    features[currentFeatureKey] = {
      'description': currentFeatureDescription.join('\n'),  
    };
  }

  if (table.isNotEmpty) {
    final Map<String, dynamic> filteredFeatures = <String, dynamic>{};
    for (final feature in features.keys) {
      for (final entry in table) {
        final int levelEntry = fromOrdinal(entry['Level'] as String? ?? '');
        if ((entry['Features'] ?? '')
                .toString()
                .toLowerCase()
                .contains(feature.toLowerCase()) &&
            levelEntry <= level) {
          filteredFeatures[feature] = features[feature];
        }
      }
    }
    return filteredFeatures;
  }

  return features;
}

Map<String, dynamic> getBackpackItem(
  Map<String, dynamic> character,
  String item,
) {
  final Map<String, dynamic> backpack =
      character['backpack'] as Map<String, dynamic>? ?? {};
  final Map<String, dynamic> backpackItems =
      backpack['items'] as Map<String, dynamic>? ?? {};
  final Map<String, dynamic> backpackItem = backpackItems.entries
      .firstWhere(
        (element) => element.key == item,
        orElse: () => MapEntry<String, dynamic>(
          item,
          {'isEquipped': false, 'quantity': 0},
        ),
      )
      .value as Map<String, dynamic>;

  return backpackItem;
}

bool isEquipable(Map<String, dynamic> item) {
  return item['armor_class'] != null || item['damage'] != null;
}

double getCostTotal(String costUnit, int costValue, double quantity) {
  switch (costUnit) {
    case 'cp':
      return costValue.toDouble() / 100.0 * quantity;
    case 'sp':
      return costValue.toDouble() / 10.0 * quantity;
    case 'gp':
      return costValue.toDouble() * quantity;
    default:
      return 0;
  }
}

Color? rarityToColor(String? rarity) {
  switch (rarity) {
    case 'Common':
      return null;
    case 'Uncommon':
      return Colors.green;
    case 'Rare':
      return Colors.blue;
    case 'Very Rare':
      return Colors.purple;
    case 'Legendary':
      return Colors.orange;
    case 'Artifact':
      return Colors.red;
    default:
      return null;
  }
}

EquipmentType getEquipmentTypeFromItem(Map<String, dynamic> item) {
  var type = getEquipmentType(item['index']?.toString() ?? '');
  if (type != EquipmentType.unknown) {
    return type;
  }
  type = getEquipmentType(item['tool_category']?.toString() ?? '');
  if (type != EquipmentType.unknown) {
    return type;
  }
  type = getEquipmentType(
    (item['gear_category'] as Map?)?['name']?.toString() ?? '',
  );
  if (type != EquipmentType.unknown) {
    return type;
  }
  type = getEquipmentType(
    (item['equipment_category'] as Map?)?['name']?.toString() ?? '',
  );
  if (type != EquipmentType.unknown) {
    return type;
  }
  return EquipmentType.unknown;
}

EquipmentType getEquipmentType(String name) {
  if (name.isEmpty) {
    return EquipmentType.unknown;
  }
  final equipment = name.toLowerCase().replaceAll(' ', '-').replaceAll("'", '');
  if (equipment.contains('clothes')) {
    return EquipmentType.clothes;
  }
  if (equipment.contains('rations')) {
    return EquipmentType.food;
  }
  switch (equipment) {
    case 'torch':
      return EquipmentType.torch;
    case 'ammunition':
      return EquipmentType.ammunition;
    case 'adventuring-gear':
      return EquipmentType.adventure;

    case 'arcane-foci':
    case 'druidic-foci':
    case 'holy-symbols':
    case 'rod':
    case 'staff':
    case 'wand':
      return EquipmentType.magic;

    case 'armor':
    case 'heavy-armor':
    case 'medium-armor':
    case 'light-armor':
      return EquipmentType.armor;

    case 'artisans-tools':
    case 'kits':
    case 'tools':
      return EquipmentType.profession;

    case 'equipment-packs':
    case 'gaming-sets':
    case 'other-tools':
    case 'standard-gear':
      return EquipmentType.misc;

    case 'land-vehicles':
    case 'mounts-and-other-animals':
    case 'mounts-and-vehicles':
    case 'tack-harness-and-drawn-vehicles':
    case 'waterborne-vehicles':
      return EquipmentType.mount;

    case 'martial-ranged-weapons':
    case 'ranged-weapons':
    case 'simple-ranged-weapons':
      return EquipmentType.rangedWeapons;

    case 'martial-melee-weapons':
    case 'simple-melee-weapons':
    case 'simple-weapons':
    case 'weapon':
      return EquipmentType.meleeWeapons;

    case 'musical-instruments':
    case 'music':
      return EquipmentType.music;

    case 'wondrous-items':
      return EquipmentType.special;

    case 'potion':
      return EquipmentType.consumable;

    case 'rings':
      return EquipmentType.accessories;

    case 'shield':
      return EquipmentType.shield;

    case 'scroll':
      return EquipmentType.scroll;

    default:
      return EquipmentType.unknown;
  }
}

int getTotalWeight(Map<String, dynamic> backpack, Map<String, dynamic> items) {
  int totalWeight = 0;
  if (backpack.isEmpty) {
    return totalWeight;
  }
  for (final itemBackpack in backpack.entries) {
    final item = items[itemBackpack.key] as Map? ?? {};
    if (item['cost'] == null ||
        (item['cost'] as Map)['unit'] == null ||
        (item['cost'] as Map)['quantity'] == null ||
        (itemBackpack.value as Map?)?['quantity'] == null) {
      continue;
    }
    final quantity = (itemBackpack.value as Map)['quantity'] as double? ?? 0.0;
    final costMap = item['cost'] as Map;
    final cost = int.tryParse(costMap['quantity'].toString()) ?? 0;
    final costTotal = getCostTotal(
      costMap['unit']?.toString() ?? '',
      cost,
      quantity,
    );
    totalWeight += costTotal.toInt();
  }
  return totalWeight;
}

List<Map<String, dynamic>> getArchetypes(Map<String, dynamic> classs) {
  final archetypeList = (classs['archetypes'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList() ??
      [];
  return archetypeList;
}

Map<String, int> getAsi(Map<String, dynamic> character) {
  final asi = (character['asi'] as Map<dynamic, dynamic>?)
          ?.map((key, value) => MapEntry(key as String, value as int)) ??
      {
        'strength': 10,
        'dexterity': 10,
        'constitution': 10,
        'intelligence': 10,
        'wisdom': 10,
        'charisma': 10,
      };
  return asi;
}

Map<String, int> getExpendedSlots(Map<String, dynamic> character) {
  final expendedSlotsMap =
      (character['expended_spell_slots'] as Map<dynamic, dynamic>?)
              ?.map((key, value) => MapEntry(key.toString(), value as int)) ??
          {};
  return expendedSlotsMap;
}

Icon? itemToIcon(Map<String, dynamic> item) {
  if (item['index']?.toString().isEmpty ?? true) {
    return null;
  }
  if (item['index']?.toString().contains('bow') ?? false) {
    return const Icon(RpgAwesome.crossbow);
  }
  if (item['index']?.toString().contains('dagger') ?? false) {
    return const Icon(RpgAwesome.plain_dagger);
  }
  if (item['armor_category'] != null &&
      (item['armor_category'].toString().toLowerCase().contains('medium') ||
          item['armor_category'].toString().toLowerCase().contains('heavy'))) {
    return const Icon(RpgAwesome.vest);
  }
  return null;
}

Icon equipmentTypeToIcon(EquipmentType type) {
  switch (type) {
    case EquipmentType.backpack:
      return const Icon(Maki.shop);
    case EquipmentType.bedroll:
      return const Icon(FontAwesome5.bed);
    case EquipmentType.clothes:
      return const Icon(FontAwesome5.tshirt);
    case EquipmentType.food:
      return const Icon(FontAwesome.food);
    case EquipmentType.waterskin:
      return const Icon(RpgAwesome.round_bottom_flask);
    case EquipmentType.ammunition:
      return const Icon(RpgAwesome.arrow_cluster);
    case EquipmentType.adventure:
      return const Icon(Icons.backpack);
    case EquipmentType.magic:
      return const Icon(RpgAwesome.fairy_wand);
    case EquipmentType.armor:
      return const Icon(RpgAwesome.vest);
    case EquipmentType.profession:
      return const Icon(Icons.star);
    case EquipmentType.music:
      return const Icon(Icons.music_note);
    case EquipmentType.misc:
      return const Icon(FontAwesome5.tools);
    case EquipmentType.mount:
      return const Icon(FontAwesome5.horse);
    case EquipmentType.rangedWeapons:
      return const Icon(RpgAwesome.crossbow);
    case EquipmentType.meleeWeapons:
      return const Icon(RpgAwesome.broadsword);
    case EquipmentType.special:
      return const Icon(Octicons.north_star);
    case EquipmentType.consumable:
      return const Icon(FontAwesome5.flask);
    case EquipmentType.accessories:
      return const Icon(FontAwesome5.ring);
    case EquipmentType.shield:
      return const Icon(Octicons.shield);
    case EquipmentType.scroll:
      return const Icon(RpgAwesome.book);
    case EquipmentType.torch:
      return const Icon(RpgAwesome.torch);
    case EquipmentType.unknown:
      return const Icon(RpgAwesome.torch);
    default:
      return const Icon(Icons.help);
  }
}

Future<String?> readConfig(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<void> saveConfig(String key, String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Map<int, int> getSpellSlotsForLevel(
  List<Map<String, dynamic>> table,
  int level,
) {
  final entry = table.firstWhere(
    (element) => element['Level'] == getOrdinal(level),
    orElse: () => <String, dynamic>{},
  );

  if (entry.isEmpty) {
    return {};
  }

  final Map<int, int> slots = {};
  for (int i = 1; i <= 9; i++) {
    final key = getOrdinal(i);
    if (entry[key] != null && entry[key] != '-') {
      slots[i] = entry[key] as int? ?? 0;
    }
  }
  return slots;
}

String getItemDescriptor(Map<String, dynamic> item) {
  final toolCategory = item['tool_category']?.toString() ?? '';
  if (toolCategory.isNotEmpty) {
    return toolCategory;
  }
  final gearCategory =
      (item['gear_category'] as Map?)?['name']?.toString() ?? '';
  if (gearCategory.isNotEmpty) {
    return gearCategory;
  }
  final equipmentCategory =
      (item['equipment_category'] as Map?)?['name']?.toString() ?? '';
  if (equipmentCategory.isNotEmpty) {
    return equipmentCategory;
  }
  return 'Misc';
}

final Map<int, List<Map<String, dynamic>>> _tableCache = {};

List<Map<String, dynamic>> parseTable(String table) {
  final int tableHash = table.hashCode;

  if (_tableCache.containsKey(tableHash)) {
    return _tableCache[tableHash]!;
  }

  final List<Map<String, dynamic>> result = [];
  final List<String> rows = table.trim().split('\n');
  final List<String> headers = rows[0]
      .split('|')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  for (var i = 1; i < rows.length; i++) {
    final List<String> rowValues = rows[i]
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (rowValues.length != headers.length) {
      throw const FormatException('Row does not match header length');
    }

    final Map<String, dynamic> rowMap = {};
    for (var j = 0; j < headers.length; j++) {
      rowMap[headers[j]] = _parseValue(rowValues[j]);
    }
    result.add(rowMap);
  }

  _tableCache[tableHash] = result;
  return result;
}

dynamic _parseValue(String value) {
  if (int.tryParse(value) != null) return int.parse(value);
  if (double.tryParse(value) != null) return double.parse(value);
  return value;
}

String parseFormula(
  String description,
  Map<String, int> attributes,
  int prof,
  int level,
) {
  final Map<String, int> values = {
    'prof': prof,
    'level': level,
  };

  for (final entry in attributes.entries) {
    final prefix = entry.key.substring(0, 3).toLowerCase();
    final modifier = getModifier(entry.value);
    values[prefix] = modifier;
  }
  final RegExp regExp = RegExp(r'\b(?:str|dex|con|int|wis|cha|prof|level)\b');

  String processed = description.replaceAllMapped(regExp, (match) {
    return values[match.group(0)]!.toString();
  });

  processed = processed.replaceAll('+-', '-');
  processed = _processFormula(processed);
  return processed;
}

String _processFormula(String formula) {
  final arithmeticRegex = RegExp(r'(?<!\d)d|(?<![d])(\d+[\+\-\*/]\d+)');

  String currentFormula = formula;
  String previousFormula;

  do {
    previousFormula = currentFormula;
    currentFormula = currentFormula.replaceAllMapped(
      arithmeticRegex,
      (match) {
        if (match.group(0)!.contains('d')) {
          return match.group(0)!;
        } else {
          return _evaluateExpression(match.group(0)!).toString();
        }
      },
    );
  } while (currentFormula != previousFormula);

  return currentFormula;
}

num _evaluateExpression(String expression) {
  final parser = buildParser();
  final result = parser.parse(expression);

  if (result is Success) {
    return result.value;
  } else {
    throw ArgumentError('Invalid expression: $expression');
  }
}

Parser<num> buildParser() {
  final builder = ExpressionBuilder<num>();

  builder.primitive(
    (char('(') & ref0(buildParser) & char(')')).map(
      (values) => values[1] as num? ?? 0,
    ),
  );
  builder.primitive(digit().plus().flatten().trim().map(num.parse));

  builder.group()
    ..left(char('*').trim(), (a, op, b) => a * b)
    ..left(char('/').trim(), (a, op, b) => a / b);

  builder.group()
    ..left(char('+').trim(), (a, op, b) => a + b)
    ..left(char('-').trim(), (a, op, b) => a - b);

  return builder.build().end();
}
