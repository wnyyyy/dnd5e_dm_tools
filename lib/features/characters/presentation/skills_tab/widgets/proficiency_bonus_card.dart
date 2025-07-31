import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProficiencyBonusCard extends StatelessWidget {
  const ProficiencyBonusCard({super.key, required this.character});
  final Character character;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 8,
              left: 12,
              right: 12,
              bottom: 4,
            ),
            child: Text(
              'Proficiency\nBonus',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Text(
                  '+${getProfBonus(character.level)}',
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    fontFamily: GoogleFonts.majorMonoDisplay().fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.star_outline,
                  size: 32,
                  color: Theme.of(context).textTheme.displaySmall!.color,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
