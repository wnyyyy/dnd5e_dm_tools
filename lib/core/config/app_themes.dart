import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static ThemeData buildThemeData(
    ThemeColor color,
    bool isDarkMode, {
    String? fontFamily,
  }) {
    return ThemeData(
      fontFamily: GoogleFonts.nunitoSans().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: isDarkMode ? color.darkColor : color.lightColor,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
    );
  }

  static MarkdownStyleSheet markdownStyleSheet(
    BuildContext context, {
    String? fontFamily,
  }) {
    final theme = Theme.of(context);
    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      h2Padding: const EdgeInsets.only(top: 16),
      h3Padding: const EdgeInsets.only(top: 20),
      h4Padding: const EdgeInsets.only(top: 22),
      h5Padding: const EdgeInsets.only(top: 24),
      blockSpacing: 4.0,
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
    }
  }

  String get name {
    switch (this) {
      case ThemeColor.chestnutBrown:
        return 'Classic';
      case ThemeColor.crimsonRed:
        return 'Flamingo Red';
      case ThemeColor.forestGreen:
        return 'Forest Green';
      case ThemeColor.midnightBlue:
        return 'Midnight Blue';
      case ThemeColor.lavenderViolet:
        return 'Lavender Violet';
      case ThemeColor.slateGrey:
        return 'Slate Grey';
    }
  }
}
