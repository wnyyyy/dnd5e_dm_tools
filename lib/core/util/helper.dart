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

Map<String, dynamic> getRacialFeatures(String desc) {
  final features = <String, dynamic>{};
  final rawFeatures = desc.split('***');

  for (var i = 1; i < rawFeatures.length; i += 2) {
    var name = rawFeatures[i].trim();
    final description = (i + 1 < rawFeatures.length)
        ? rawFeatures[i + 1].trim()
        : '';

    if (name.endsWith('.')) {
      name = name.substring(0, name.length - 1);
    }

    if (name.isNotEmpty && description.isNotEmpty) {
      features[name] = description;
    }
  }

  return features;
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
