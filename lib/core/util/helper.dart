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
