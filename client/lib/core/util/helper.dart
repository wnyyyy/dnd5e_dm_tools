import 'package:dnd5e_dm_tools/core/util/enum.dart';
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

EquipmentType getEquipmentType(String equipment) {
  switch (equipment) {
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
