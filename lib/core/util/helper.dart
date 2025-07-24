import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> readConfig(String key) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<void> saveConfig(String key, String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
  logDB('Config saved: $key = $value');
}

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

bool classPreparesSpells(String classSlug) {
  switch (classSlug.toLowerCase()) {
    case 'artificer':
    case 'wizard':
    case 'cleric':
    case 'druid':
    case 'paladin':
    case 'ranger':
      return true;
    default:
      return false;
  }
}

int fromOrdinal(String ordinal) {
  return int.tryParse(ordinal.replaceAll(RegExp('[a-zA-Z]'), '')) ?? 0;
}

List<Feat> buildFeatList(List<String> lines) {
  final featMap = _buildFeatMap(lines, '###');
  final List<Feat> featList = [];

  for (final entry in featMap.entries) {
    final featName = entry.key;
    final featDesc = List<String>.from(
      entry.value['description'] as List? ?? [],
    );
    final subfeats = <String>[];
    final Map subfeatures = entry.value['subfeatures'] as Map? ?? {};
    for (final subfeature in subfeatures.entries) {
      final subfeatName = subfeature.key;
      final subfeatureVal = subfeature.value as Map<String, dynamic>? ?? {};
      final subfeatDesc = List<String>.from(
        subfeatureVal['description'] as List? ?? [],
      );
      subfeats.add('**$subfeatName**.\n${subfeatDesc.join('\n\n')}');
    }

    featList.add(
      Feat(
        name: featName,
        description: featDesc.join('\n\n'),
        slug: featName,
        effectsDesc: subfeats,
      ),
    );
  }

  return featList;
}

Map<String, Map<String, dynamic>> _buildFeatMap(
  List<String> lines,
  String prefix,
) {
  var currFeatKey = '';
  final currFeatDesc = [];
  final featMap = <String, Map<String, dynamic>>{};
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.startsWith('$prefix ')) {
      if (currFeatKey.isNotEmpty && currFeatDesc.isNotEmpty) {
        featMap[currFeatKey] ??= {};
        featMap[currFeatKey]!['description'] = List.from(currFeatDesc);
        currFeatDesc.clear();
      }
      final featName = line.substring(prefix.length).trim();
      currFeatKey = featName;
      featMap[currFeatKey] = {};
    } else if (line.startsWith('$prefix# ')) {
      if (currFeatKey.isNotEmpty && currFeatDesc.isNotEmpty) {
        featMap[currFeatKey] ??= {};
        featMap[currFeatKey]!['description'] = List.from(currFeatDesc);
        currFeatDesc.clear();
      }
      final subfeatLines = lines
          .skip(i)
          .takeWhile((l) => !l.startsWith('$prefix '))
          .toList();
      featMap[currFeatKey]!['subfeatures'] = _buildFeatMap(
        subfeatLines,
        '$prefix#',
      );
      i += subfeatLines.length - 1;
    } else {
      if (currFeatKey.isNotEmpty) {
        currFeatDesc.add(line.trim());
        featMap[currFeatKey] ??= {};
        featMap[currFeatKey]!['description'] = List.from(currFeatDesc);
      }
    }
  }
  return featMap;
}
