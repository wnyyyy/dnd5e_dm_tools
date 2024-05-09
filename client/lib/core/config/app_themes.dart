import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData buildThemeData(ThemeColor color, bool isDarkMode) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: isDarkMode ? color.darkColor : color.lightColor,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
    );
  }
}

extension ThemeColorExtension on ThemeColor {
  Color get lightColor {
    switch (this) {
      case ThemeColor.chestnutBrown:
        return Colors.yellow;
      case ThemeColor.crimsonRed:
        return Colors.red.shade700;
      case ThemeColor.forestGreen:
        return const Color(0xFF013220);
      case ThemeColor.midnightBlue:
        return const Color(0xFF00008B);
      case ThemeColor.lavenderViolet:
        return const Color(0xFF8A2BE2);
      case ThemeColor.slateGrey:
        return Colors.grey.shade600;
      default:
        return Colors.black;
    }
  }

  Color get darkColor {
    switch (this) {
      case ThemeColor.chestnutBrown:
        return Colors.brown;
      case ThemeColor.crimsonRed:
        return Colors.red.shade900;
      case ThemeColor.forestGreen:
        return const Color(0xFF002411);
      case ThemeColor.midnightBlue:
        return const Color(0xFF00004D);
      case ThemeColor.lavenderViolet:
        return const Color(0xFF551A8B);
      case ThemeColor.slateGrey:
        return Colors.grey.shade900;
      default:
        return Colors.black;
    }
  }

  String get name {
    switch (this) {
      case ThemeColor.chestnutBrown:
        return "Classic";
      case ThemeColor.crimsonRed:
        return "Crimson Red";
      case ThemeColor.forestGreen:
        return "Forest Green";
      case ThemeColor.midnightBlue:
        return "Midnight Blue";
      case ThemeColor.lavenderViolet:
        return "Lavender Violet";
      case ThemeColor.slateGrey:
        return "Slate Grey";
      default:
        return "Unknown";
    }
  }
}
