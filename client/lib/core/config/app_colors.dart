import 'package:flutter/material.dart';

extension AppColors on ThemeData {
  Color get strengthColor => this.brightness == Brightness.dark
      ? Colors.deepOrange.shade500
      : Colors.deepOrange.shade800;
  Color get dexterityColor => this.brightness == Brightness.dark
      ? Colors.green.shade500
      : Colors.green.shade800;
  Color get constitutionColor => this.brightness == Brightness.dark
      ? Colors.brown.shade300
      : Colors.brown.shade500;
  Color get intelligenceColor => this.brightness == Brightness.dark
      ? Colors.indigo.shade300
      : Colors.indigo.shade500;
  Color get wisdomColor => this.brightness == Brightness.dark
      ? Colors.yellowAccent.shade700
      : Colors.lime.shade700;
  Color get charismaColor => this.brightness == Brightness.dark
      ? Colors.purpleAccent
      : Colors.purpleAccent.shade400;
}
