import 'package:dnd5e_dm_tools/core/data/models/asi.dart';
import 'package:dnd5e_dm_tools/core/data/models/class_table.dart';
import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:petitparser/petitparser.dart';
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

String parseFormula(
  String description,
  ASI asi,
  int prof,
  int level,
  ClassTable classTable,
) {
  final Map<String, int> values = {'prof': prof, 'level': level};
  final attributes = {
    Attribute.strength: asi.strength,
    Attribute.dexterity: asi.dexterity,
    Attribute.constitution: asi.constitution,
    Attribute.intelligence: asi.intelligence,
    Attribute.wisdom: asi.wisdom,
    Attribute.charisma: asi.charisma,
  };

  for (final entry in attributes.entries) {
    final prefix = entry.key.name.substring(0, 3).toLowerCase();
    final modifier = getModifier(entry.value);
    values[prefix] = modifier;
  }

  final RegExp bracketRegExp = RegExp(r'\[([^\]]+)\]');
  String processed = description.replaceAllMapped(bracketRegExp, (match) {
    final key = match.group(1)?.toLowerCase();
    final classTableRow = classTable.levelData[level];
    if (key != null &&
        classTableRow != null &&
        classTableRow.classSpecificFeatures != null) {
      final features = classTableRow.classSpecificFeatures!;
      final foundKey = features.keys.firstWhere(
        (k) => k.toLowerCase() == key.toLowerCase(),
        orElse: () => '',
      );
      if (foundKey.isNotEmpty) {
        return features[foundKey]!.toString();
      }
    }
    return match.group(0)!;
  });

  final RegExp regExp = RegExp(r'\b(?:str|dex|con|int|wis|cha|prof|level)\b');

  processed = processed.replaceAllMapped(regExp, (match) {
    return values[match.group(0)]!.toString();
  });

  processed = processed.replaceAll('+-', '-');

  final diceRegex = RegExp(r'\d+d\d+');
  final dicePlaceholders = <String>[];
  int diceIndex = 0;

  processed = processed.replaceAllMapped(diceRegex, (match) {
    final placeholder = '__DICE__${diceIndex}__';
    dicePlaceholders.add(match.group(0)!);
    diceIndex++;
    return placeholder;
  });

  processed = _processFormula(processed);

  processed = processed.splitMapJoin(
    RegExp(r'([+\-*/])'),
    onMatch: (m) => ' ${m.group(0)} ',
    onNonMatch: (n) => n,
  );

  for (int i = 0; i < dicePlaceholders.length; i++) {
    processed = processed.replaceAll('__DICE__${i}__', dicePlaceholders[i]);
  }

  return processed;
}

bool isMagicInitiate(List<Feat> feats) {
  return feats.any(
    (feat) =>
        feat.name.toLowerCase() == 'magic initiate' ||
        feat.slug.toLowerCase() == 'magic-initiate' ||
        feat.slug.toLowerCase() == 'magic_initiate',
  );
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

      final StringBuffer descBuffer = StringBuffer();
      for (final line in subfeatDesc) {
        if (line.isNotEmpty) {
          if (line.startsWith('|')) {
            descBuffer.writeln(line);
          } else {
            descBuffer.writeln('\n$line');
          }
        }
      }
      subfeats.add('**$subfeatName**.\n${descBuffer.toString().trim()}');
    }
    final StringBuffer descBuffer = StringBuffer();
    for (final line in featDesc) {
      if (line.isNotEmpty) {
        if (line.startsWith('|')) {
          descBuffer.writeln(line);
        } else {
          descBuffer.writeln('\n$line');
        }
      }
    }

    featList.add(
      Feat(
        name: featName,
        description: descBuffer.toString().trim(),
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

String _processFormula(String formula) {
  final arithmeticRegex = RegExp(r'(?<!\d)d|(?<![d])(\d+[\+\-\*/]\d+)');

  String currentFormula = formula;
  String previousFormula;

  do {
    previousFormula = currentFormula;
    currentFormula = currentFormula.replaceAllMapped(arithmeticRegex, (match) {
      if (match.group(0)!.contains('d')) {
        return match.group(0)!;
      } else {
        return _evaluateExpression(match.group(0)!).toString();
      }
    });
  } while (currentFormula != previousFormula);

  return currentFormula;
}

num _evaluateExpression(String expression) {
  final parser = _buildParser();
  final result = parser.parse(expression);

  if (result is Success) {
    return result.value;
  } else {
    throw ArgumentError('Invalid expression: $expression');
  }
}

Parser<num> _buildParser() {
  final builder = ExpressionBuilder<num>();

  builder.primitive(
    (char('(') & ref0(_buildParser) & char(')')).map(
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
