import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

int getModifier(int value) {
  return (value - 10) ~/ 2;
}

int getProfBonus(int level) {
  return ((level - 1) ~/ 4) + 2;
}

String getOrdinal(int number) {
  int lastDigit = number % 10;
  int lastTwoDigits = number % 100;

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
  var type = getEquipmentType(item['index']);
  if (type != EquipmentType.unknown) {
    return type;
  }
  type = getEquipmentType(item['tool_category'] ?? '');
  if (type != EquipmentType.unknown) {
    return type;
  }
  type = getEquipmentType(item['gear_category']?['name'] ?? '');
  if (type != EquipmentType.unknown) {
    return type;
  }
  type = getEquipmentType(item['equipment_category']?['name'] ?? '');
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
  for (var itemBackpack in backpack.entries) {
    final item = items[itemBackpack.key];
    if (item == null ||
        item['cost'] == null ||
        item['cost']['unit'] == null ||
        item['cost']['quantity'] == null ||
        itemBackpack.value['quantity'] == null) {
      continue;
    }
    final cost = int.tryParse(item['cost']['quantity'].toString()) ?? 0;
    final costTotal = getCostTotal(
        item['cost']['unit'], cost, itemBackpack.value['quantity'].toDouble());
    totalWeight += costTotal.toInt();
  }
  return totalWeight;
}

Icon? itemToIcon(Map<String, dynamic> item) {
  if (item['index'].isEmpty) {
    return null;
  }
  if (item['index'].contains('bow')) {
    return const Icon(RpgAwesome.crossbow);
  }
  if (item['index'].contains('dagger')) {
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
    case EquipmentType.ammunition:
      return const Icon(RpgAwesome.arrow_cluster);
    case EquipmentType.adventure:
      return const Icon(Icons.backpack);
    case EquipmentType.magic:
      return const Icon(RpgAwesome.fairy_wand);
    case EquipmentType.armor:
      return const Icon(FontAwesome5.tshirt);
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

Map<int, int> getSpellSlotsForLevel(List<dynamic> table, int level) {
  var entry = table.firstWhere(
      (element) => element['Level'] == getOrdinal(level),
      orElse: () => <String, dynamic>{});
  if (entry.isEmpty) {
    return {};
  }

  Map<int, int> slots = {};
  for (int i = 1; i <= 9; i++) {
    final key = getOrdinal(i);
    if (entry[key] != null && entry[key] != '-') {
      slots[i] = entry[key];
    }
  }
  return slots;
}

String getItemDescriptor(Map<String, dynamic> item) {
  return item['tool_category'] ??
      item['gear_category']?['name'] ??
      item['equipment_category']?['name'] ??
      'Misc';
}

final Map<int, List<Map<String, dynamic>>> _tableCache = {};

List<Map<String, dynamic>> parseTable(String table) {
  int tableHash = table.hashCode;

  if (_tableCache.containsKey(tableHash)) {
    return _tableCache[tableHash]!;
  }

  List<Map<String, dynamic>> result = [];
  List<String> rows = table.trim().split('\n');
  List<String> headers = rows[0]
      .split('|')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  for (var i = 1; i < rows.length; i++) {
    List<String> rowValues = rows[i]
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (rowValues.length != headers.length) {
      throw const FormatException('Row does not match header length');
    }

    Map<String, dynamic> rowMap = {};
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
