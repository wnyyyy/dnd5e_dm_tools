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
