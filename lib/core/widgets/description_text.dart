import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dnd5e_dm_tools/core/config/app_colors.dart';
import 'package:dnd5e_dm_tools/core/data/models/condition.dart';
import 'package:dnd5e_dm_tools/core/widgets/trait_description.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DescriptionText extends StatelessWidget {
  const DescriptionText({
    super.key,
    required this.inputText,
    required this.baseStyle,
    this.addTabSpace = false,
    this.textAlign = TextAlign.left,
  });

  final String inputText;
  final TextStyle baseStyle;
  final bool addTabSpace;
  final TextAlign textAlign;

  static final Map<String, List<TextSpan>> _cache = {};

  @override
  Widget build(BuildContext context) {
    var preProcess = inputText.replaceAll('**_', '**');
    preProcess = preProcess.replaceAll('_**', '**');
    preProcess = preProcess.replaceAll('_', '**');

    final inputHash = md5.convert(utf8.encode(preProcess)).toString();

    if (_cache.containsKey(inputHash)) {
      return RichText(
        textAlign: textAlign,
        text: TextSpan(children: _cache[inputHash]),
      );
    }

    final processedSpans = _postProcess(_processText(preProcess, context));
    _cache[inputHash] = processedSpans;

    return RichText(
      textAlign: textAlign,
      text: TextSpan(children: processedSpans),
    );
  }

  List<TextSpan> _processText(String text, BuildContext context) {
    final conditions =
        (context.read<RulesCubit>().state as RulesStateLoaded).conditions;
    final List<TextSpan> spans = [];
    final String tabSpace = addTabSpace ? '    ' : '';
    if (addTabSpace) {
      spans.add(TextSpan(text: tabSpace, style: baseStyle));
    }

    final attributeColors = {
      'wis': Theme.of(context).wisdomColor,
      'wisdom': Theme.of(context).wisdomColor,
      'str': Theme.of(context).strengthColor,
      'strength': Theme.of(context).strengthColor,
      'dex': Theme.of(context).dexterityColor,
      'dexterity': Theme.of(context).dexterityColor,
      'con': Theme.of(context).constitutionColor,
      'constitution': Theme.of(context).constitutionColor,
      'int': Theme.of(context).intelligenceColor,
      'intelligence': Theme.of(context).intelligenceColor,
      'cha': Theme.of(context).charismaColor,
      'charisma': Theme.of(context).charismaColor,
    };

    final skillAttributes = {
      'acrobatics': 'dex',
      'animal handling': 'wis',
      'arcana': 'int',
      'athletics': 'str',
      'deception': 'cha',
      'history': 'int',
      'insight': 'wis',
      'intimidation': 'cha',
      'investigation': 'int',
      'medicine': 'wis',
      'nature': 'int',
      'perception': 'wis',
      'performance': 'cha',
      'persuasion': 'cha',
      'religion': 'int',
      'sleight of hand': 'dex',
      'stealth': 'dex',
      'survival': 'wis',
    };

    final damageTypeColors = {
      'acid': Colors.green,
      'bludgeoning': Colors.blueGrey,
      'cold': Colors.cyan,
      'fire': Colors.red,
      'force': Colors.lightGreen,
      'lightning': Colors.yellow.shade800,
      'necrotic': Colors.deepPurple,
      'piercing': Colors.blueGrey,
      'poison': Colors.lime,
      'psychic': Colors.deepPurpleAccent,
      'radiant': Colors.yellow.shade900,
      'slashing': Colors.blueGrey,
      'thunder': Colors.blueAccent,
    };

    final regex = RegExp(
      r'(\d+\s?(ft|feet|foot|radius|minutes|minute|hours|hour))|\b(successful|success|failure|fail|fails|succeed)\b|(\d+d\d+|d\d+)( \w+)?',
      caseSensitive: false,
    );

    text.splitMapJoin(
      regex,
      onMatch: (Match match) {
        final fullMatch = match[0]!;
        if (match[1] != null) {
          // Handling units such as feet, foot, radius, hour, and minute
          spans.add(
            TextSpan(
              text: fullMatch,
              style: baseStyle.copyWith(fontWeight: FontWeight.bold),
            ),
          );
        } else if (match[3] != null) {
          // Handling words like 'successful', 'failure', etc.
          spans.add(
            TextSpan(
              text: fullMatch,
              style: baseStyle.copyWith(
                color: (fullMatch.toLowerCase().contains('fail'))
                    ? Colors.red
                    : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else if (match[4] != null) {
          // Handling damage dice
          final Color? color = match[5] != null
              ? damageTypeColors[match[5]!.trim().toLowerCase()]
              : null;
          spans.add(
            TextSpan(
              text: fullMatch,
              style: baseStyle.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          );
        }
        return '';
      },
      onNonMatch: (String text) {
        final parts = text.split('**');
        for (var i = 0; i < parts.length; i++) {
          if (i.isOdd) {
            spans.add(
              TextSpan(
                text: parts[i],
                style: baseStyle.copyWith(fontWeight: FontWeight.bold),
              ),
            );
          } else {
            final lines = parts[i].split('\n');
            for (var j = 0; j < lines.length; j++) {
              final words = lines[j].split(
                RegExp(r'(\s+|(?=\p{P})|(?<=\p{P})(?<!\d,))', unicode: true),
              );
              for (var k = 0; k < words.length; k++) {
                if (words[k].isEmpty) continue;
                final lowerWord = words[k].toLowerCase();

                // Handle multi-word skills
                bool matchedSkill = false;
                for (final skill in skillAttributes.keys) {
                  final skillWords = skill.split(' ');
                  if (k + skillWords.length <= words.length) {
                    final combinedWords = words
                        .sublist(k, k + skillWords.length)
                        .join(' ')
                        .toLowerCase();
                    if (combinedWords == skill) {
                      spans.add(
                        TextSpan(
                          text: words
                              .sublist(k, k + skillWords.length)
                              .join(' '),
                          style: baseStyle.copyWith(
                            color: attributeColors[skillAttributes[skill]],
                          ),
                        ),
                      );
                      k += skillWords.length - 1;
                      matchedSkill = true;
                      break;
                    }
                  }
                }
                if (matchedSkill) continue;

                // Handle single-word skills, attributes, conditions, and damage types
                if (attributeColors.containsKey(lowerWord)) {
                  spans.add(
                    TextSpan(
                      text: words[k],
                      style: baseStyle.copyWith(
                        color: attributeColors[lowerWord],
                      ),
                    ),
                  );
                } else if (damageTypeColors.containsKey(lowerWord)) {
                  spans.add(
                    TextSpan(
                      text: words[k],
                      style: baseStyle.copyWith(
                        color: damageTypeColors[lowerWord],
                      ),
                    ),
                  );
                } else if (conditions.any(
                  (condition) => condition.name.toLowerCase() == lowerWord,
                )) {
                  spans.add(
                    TextSpan(
                      text: words[k],
                      style: baseStyle.copyWith(fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              final Condition condition = conditions.firstWhere(
                                (c) => c.name.toLowerCase() == lowerWord,
                              );
                              return AlertDialog(
                                title: Text(condition.name),
                                content: TraitDescription(
                                  inputText: condition.description,
                                  separator: '*',
                                  boldify: false,
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Icon(Icons.done),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                    ),
                  );
                } else {
                  spans.add(TextSpan(text: words[k], style: baseStyle));
                }
              }
              if (j < lines.length - 1) {
                spans.add(const TextSpan(text: '\n'));
              }
            }
          }
        }
        return '';
      },
    );

    return spans;
  }

  List<TextSpan> _postProcess(List<TextSpan> spans) {
    final List<TextSpan> processedSpans = [];
    for (int i = 0; i < spans.length; i++) {
      processedSpans.add(spans[i]);
      final previousSpan = i > 0 ? spans[i - 1] : null;
      final nextSpan = i < spans.length - 1 ? spans[i + 1] : null;
      final isNumSeparator = _isNumSeparator(previousSpan, spans[i], nextSpan);
      if (i < spans.length - 1 &&
          _needsSpace(spans[i], nextSpan) &&
          !isNumSeparator) {
        processedSpans.add(const TextSpan(text: ' '));
      }
      if (isNumSeparator) {
        final correctionIndex = processedSpans.length - 2;
        if (correctionIndex >= 0) {
          final style = nextSpan?.style ?? baseStyle;
          processedSpans[correctionIndex] = TextSpan(
            text: processedSpans[correctionIndex].text,
            style: style,
          );
          processedSpans[correctionIndex + 1] = TextSpan(
            text: processedSpans[correctionIndex + 1].text,
            style: style,
          );
        }
      }
    }
    return _processCompoundWords(_removeDuplicateSpaces(processedSpans));
  }

  bool _isNumSeparator(
    TextSpan? previousSpan,
    TextSpan currentSpan,
    TextSpan? nextSpan,
  ) {
    if (currentSpan.text != null && currentSpan.text == ',') {
      if (previousSpan == null || nextSpan == null) return true;
      if (nextSpan.text == null || previousSpan.text == null) return true;
      final prevSpanTextArr = previousSpan.text!.split(' ');
      final lastElement = prevSpanTextArr.last;
      bool isNumLast = true;
      try {
        int.parse(lastElement);
      } catch (e) {
        isNumLast = false;
      }
      final nextSpanTextArr = nextSpan.text!.split(' ');
      final firstElement = nextSpanTextArr.first;
      bool isNumFirst = true;
      try {
        int.parse(firstElement);
      } catch (e) {
        isNumFirst = false;
      }
      if (isNumLast && isNumFirst) {
        return true;
      }
    }
    return false;
  }

  bool _needsSpace(TextSpan currentSpan, TextSpan? nextSpan) {
    if (nextSpan == null) return false;
    if (currentSpan.text == null || nextSpan.text == null) return false;
    final currentText = currentSpan.text!;
    final nextText = nextSpan.text!;
    if (currentText == '-') {
      return true;
    }
    final noSpaceBefore = RegExp(r"[.,;:!?'\’]");
    final noSpaceAfterCloseParen = RegExp(r'^\)');
    final noSpaceBeforeOpenParen = RegExp(r'\($');
    return !noSpaceBefore.hasMatch(nextText) &&
        !currentText.endsWith('\n') &&
        !noSpaceAfterCloseParen.hasMatch(nextText) &&
        !noSpaceBeforeOpenParen.hasMatch(currentText);
  }

  List<TextSpan> _removeDuplicateSpaces(List<TextSpan> spans) {
    final List<TextSpan> processedSpans = [];
    for (int i = 0; i < spans.length; i++) {
      if (i > 0 &&
          spans[i].text == ' ' &&
          processedSpans.isNotEmpty &&
          processedSpans.last.text == ' ') {
        continue;
      }
      if (i > 0 &&
          spans[i].text == ' ' &&
          processedSpans.isNotEmpty &&
          processedSpans.last.text != null &&
          spans.length > i + 1 &&
          spans[i + 1].text != null &&
          (processedSpans.last.text!.endsWith("'") ||
              processedSpans.last.text!.endsWith('’')) &&
          (spans[i + 1].text! == 're' ||
              spans[i + 1].text! == 've' ||
              spans[i + 1].text! == 'll' ||
              spans[i + 1].text! == 'd' ||
              spans[i + 1].text! == 't' ||
              spans[i + 1].text! == 's')) {
        continue;
      }
      // Remove spaces around hyphens in the middle of words
      if (i > 0 &&
          spans[i].text == ' ' &&
          spans[i - 1].text != null &&
          spans[i + 1].text != null) {
        final previousText = spans[i - 1].text!;
        final nextText = spans[i + 1].text!;
        if (previousText.endsWith('-') || nextText.startsWith('-')) {
          bool isNewParagraph = false;
          try {
            final antipreviousSpan = spans[i - 2];
            if (antipreviousSpan.text != null &&
                antipreviousSpan.text!.endsWith('\n')) {
              isNewParagraph = true;
            }
          } catch (e) {
            isNewParagraph = false;
          }
          if (!isNewParagraph) {
            continue;
          }
        }
      }
      processedSpans.add(spans[i]);
    }
    return processedSpans;
  }

  List<TextSpan> _processCompoundWords(List<TextSpan> spans) {
    final List<TextSpan> processedSpans = [];
    final compoundRegex = RegExp(
      r'\b(\d+-\w*(feet|foot|ft|hour|minute|minutes|hours)\b(?:-\w+)?)',
      caseSensitive: false,
    );

    for (final span in spans) {
      final text = span.text ?? '';
      final matches = compoundRegex.allMatches(text);
      if (matches.isEmpty) {
        processedSpans.add(span);
        continue;
      }

      int lastEnd = 0;
      for (final match in matches) {
        if (match.start > lastEnd) {
          processedSpans.add(
            TextSpan(
              text: text.substring(lastEnd, match.start),
              style: span.style,
            ),
          );
        }
        processedSpans.add(
          TextSpan(
            text: match.group(0),
            style: span.style?.copyWith(fontWeight: FontWeight.bold),
          ),
        );
        lastEnd = match.end;
      }

      if (lastEnd < text.length) {
        processedSpans.add(
          TextSpan(text: text.substring(lastEnd), style: span.style),
        );
      }
    }

    return processedSpans;
  }
}
