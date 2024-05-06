import 'package:flutter/material.dart';

extension AppColors on ThemeData {
  Color get strengthColor => brightness == Brightness.dark
      ? Colors.deepOrange.shade500
      : Colors.deepOrange.shade800;
  Color get dexterityColor => brightness == Brightness.dark
      ? Colors.green.shade500
      : Colors.green.shade800;
  Color get constitutionColor => brightness == Brightness.dark
      ? Colors.brown.shade300
      : Colors.brown.shade500;
  Color get intelligenceColor => brightness == Brightness.dark
      ? Colors.indigo.shade300
      : Colors.indigo.shade500;
  Color get wisdomColor => brightness == Brightness.dark
      ? Colors.yellowAccent.shade700
      : Colors.lime.shade700;
  Color get charismaColor => brightness == Brightness.dark
      ? Colors.purpleAccent
      : Colors.purpleAccent.shade400;
}
