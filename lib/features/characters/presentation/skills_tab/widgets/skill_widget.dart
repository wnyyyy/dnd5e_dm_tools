import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SkillWidget extends StatelessWidget {
  const SkillWidget({
    super.key,
    required this.skill,
    required this.attributeValue,
    required this.color,
    this.proficiency,
    this.hasExpertise = false,
  });
  final Skill skill;
  final int attributeValue;
  final int? proficiency;
  final bool hasExpertise;
  final Color color;

  @override
  Widget build(BuildContext context) {
    var value = proficiency != null
        ? getModifier(attributeValue) + proficiency!
        : getModifier(attributeValue);
    if (hasExpertise) {
      value += proficiency ?? 0;
    }
    final valueStr = value >= 0 ? '+$value' : value.toString();

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        children: [
          if (proficiency != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Icon(Icons.star_outline, color: color, size: 16),
            ),
          ],
          if (hasExpertise) ...[
            Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(Icons.star, color: color, size: 16),
            ),
          ],
          Text(
            skill.name,
            style: Theme.of(
              context,
            ).textTheme.labelMedium!.copyWith(color: color),
          ),
          Flex(
            direction: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  valueStr,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    fontFamily: GoogleFonts.sourceCodePro().fontFamily,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
