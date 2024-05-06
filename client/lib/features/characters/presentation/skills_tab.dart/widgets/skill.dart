import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Skill extends StatelessWidget {
  final String skillName;
  final String attributeName;
  final int? proficiency;
  final Color color;
  final Map<String, dynamic> character;

  const Skill({
    super.key,
    required this.skillName,
    required this.attributeName,
    this.proficiency,
    required this.color,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    final attrValue = character['asi'][attributeName.toLowerCase()];
    final value = proficiency != null
        ? getModifier(attrValue) + proficiency!
        : getModifier(attrValue);
    final valueStr = value >= 0 ? '+$value' : value.toString();
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        children: [
          if (proficiency != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                Icons.star_outline,
                color: color,
                size: 16,
              ),
            ),
          ],
          Text(
            skillName,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: color,
                ),
          ),
          Flex(
            direction: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  valueStr,
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        fontFamily: GoogleFonts.sourceCodePro().fontFamily,
                        color: color,
                      ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
