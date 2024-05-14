import 'package:dnd5e_dm_tools/core/config/app_colors.dart';
import 'package:dnd5e_dm_tools/core/widgets/trait_description2.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_states.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DescriptionText extends StatelessWidget {
  final String inputText;
  final TextStyle baseStyle;
  final bool addTabSpace;

  const DescriptionText({
    super.key,
    required this.inputText,
    required this.baseStyle,
    this.addTabSpace = false,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        children: _processText(inputText, context),
      ),
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
      r'(\d+\s?(ft|feet|hp|hitpoints))|\b(successful|success|failure|fail|fails|succeed)\b|(\d+d\d+)( \w+)?',
      caseSensitive: false,
    );

    text.splitMapJoin(
      regex,
      onMatch: (Match match) {
        final fullMatch = match[0]!;
        if (match[1] != null) {
          // Handling units such as feet and hitpoints
          spans.add(TextSpan(
            text: fullMatch,
            style: baseStyle.copyWith(
                color: Colors.blueAccent, fontWeight: FontWeight.bold),
          ));
        } else if (match[3] != null) {
          // Handling words like 'successful', 'failure', etc.
          spans.add(TextSpan(
            text: fullMatch,
            style: baseStyle.copyWith(
              color: (fullMatch.toLowerCase().contains('fail'))
                  ? Colors.red
                  : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ));
        } else if (match[4] != null) {
          // Handling damage dice
          Color? color = match[5] != null
              ? damageTypeColors[match[5]!.trim().toLowerCase()]
              : null;
          spans.add(TextSpan(
            text: fullMatch,
            style: baseStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ));
        }
        spans.add(const TextSpan(text: ' '));
        return '';
      },
      onNonMatch: (String text) {
        final words = text.split(' ');
        for (var word in words) {
          final lowerWord = word.toLowerCase();
          if (attributeColors.containsKey(lowerWord)) {
            spans.add(TextSpan(
              text: '$word ',
              style: baseStyle.copyWith(color: attributeColors[lowerWord]),
            ));
          } else if (conditions.containsKey(lowerWord)) {
            spans.add(TextSpan(
              text: '$word ',
              style: baseStyle.copyWith(fontWeight: FontWeight.bold),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final condition = conditions[lowerWord];
                      return AlertDialog(
                        title: Text(condition['name']),
                        content: TraitDescription2(
                          inputText: condition['desc'],
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
            ));
          } else {
            if (word.isNotEmpty) {
              spans.add(TextSpan(text: '$word ', style: baseStyle));
            }
          }
        }
        return '';
      },
    );

    return spans;
  }
}
