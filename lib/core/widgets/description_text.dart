import 'package:dnd5e_dm_tools/core/config/app_colors.dart';
import 'package:dnd5e_dm_tools/core/config/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class DescriptionText extends StatelessWidget {
  const DescriptionText({
    super.key,
    required this.inputText,
    required this.baseStyle,
    this.textAlign = TextAlign.left,
  });

  final String inputText;
  final TextStyle baseStyle;
  final TextAlign textAlign;

  static final Map<String, Color> _staticKeywordColors = {
    'acid': Colors.green[700]!,
    'bludgeoning': Colors.blueGrey,
    'cold': Colors.cyan,
    'fire': Colors.deepOrange,
    'force': Colors.lightGreen,
    'lightning': Colors.yellow,
    'necrotic': Colors.deepPurple,
    'piercing': Colors.blueGrey,
    'poison': Colors.lime,
    'psychic': Colors.deepPurpleAccent,
    'radiant': Colors.yellow,
    'slashing': Colors.blueGrey,
    'thunder': Colors.blueAccent,
    'success': Colors.green,
    'successful': Colors.green,
    'fail': Colors.red,
    'failed': Colors.red,
    'failure': Colors.red,
  };

  static final wordsToAttributes = {
    'dexterity': ['dex', 'acrobatics', 'sleight of hand', 'stealth'],
    'strength': ['str', 'strength'],
    'intelligence': [
      'int',
      'arcana',
      'history',
      'investigation',
      'nature',
      'religion',
    ],
    'wisdom': [
      'wis',
      'animal handling',
      'insight',
      'medicine',
      'perception',
      'survival',
    ],
    'charisma': [
      'cha',
      'deception',
      'intimidation',
      'performance',
      'persuasion',
    ],
  };

  static final boldWords = [
    'feet',
    'foot',
    'ft',
    'hour',
    'minute',
    'minutes',
    'hours',
    'saves',
    'action',
    'bonus action',
    'reaction',
    'radius',
    'success',
    'fail',
    'successful',
    'failed',
    'failure',
  ];

  String _highlightKeywords(String text, Map<String, Color> keywordColors) {
    var result = text;
    keywordColors.forEach((keyword, color) {
      result = result.replaceAllMapped(
        RegExp(r'\b' + RegExp.escape(keyword) + r'\b', caseSensitive: false),
        (match) => '[[${match[0]}]]',
      );
    });
    return result;
  }

  Map<String, Color> _buildKeywordColors(BuildContext context) {
    final theme = Theme.of(context);
    final attributeColors = {
      'strength': theme.strengthColor,
      'dexterity': theme.dexterityColor,
      'constitution': theme.constitutionColor,
      'intelligence': theme.intelligenceColor,
      'wisdom': theme.wisdomColor,
      'charisma': theme.charismaColor,
    };

    final Map<String, Color> keywordColors = {..._staticKeywordColors};

    wordsToAttributes.forEach((attribute, words) {
      final color = attributeColors[attribute];
      if (color != null) {
        for (final word in words) {
          keywordColors[word.toLowerCase()] = color;
        }
        keywordColors[attribute.toLowerCase()] = color;
      }
    });

    return keywordColors;
  }

  @override
  Widget build(BuildContext context) {
    final keywordColors = _buildKeywordColors(context);
    final highlighted = _highlightKeywords(inputText, keywordColors);

    return MarkdownBody(
      data: highlighted,
      styleSheet: AppThemes.markdownStyleSheet(context),
      softLineBreak: true,
      builders: {
        'keyword': KeywordBuilder(keywordColors, baseStyle, boldWords),
      },
      inlineSyntaxes: [KeywordSyntax()],
    );
  }
}

class KeywordSyntax extends md.InlineSyntax {
  KeywordSyntax() : super(r'\[\[([a-zA-Z ]+)\]\]');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final keyword = match[1]!;
    parser.addNode(md.Element.text('keyword', keyword));
    return true;
  }
}

class KeywordBuilder extends MarkdownElementBuilder {
  KeywordBuilder(this.keywordColors, this.baseStyle, this.boldWords);
  final Map<String, Color> keywordColors;
  final TextStyle baseStyle;
  final List<String> boldWords;

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final keyword = element.textContent.toLowerCase();
    final color = keywordColors[keyword] ?? baseStyle.color;
    final isBold = boldWords.contains(keyword);
    return Text(
      element.textContent,
      style: baseStyle.copyWith(
        color: color,
        fontWeight: isBold ? FontWeight.bold : baseStyle.fontWeight,
      ),
    );
  }
}
