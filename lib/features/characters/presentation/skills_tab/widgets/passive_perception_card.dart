import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PassivePerceptionCard extends StatelessWidget {
  const PassivePerceptionCard({
    super.key,
    required this.character,
    this.onLongPress,
  });
  final Character character;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: GestureDetector(
        onLongPress: onLongPress,
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
                'Passive\nPerception',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      character.stats.passivePerception.toString(),
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontFamily: GoogleFonts.majorMonoDisplay().fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, top: 4.0),
                    child: Icon(
                      Icons.search_outlined,
                      size: 24,
                      color: Theme.of(context).textTheme.displaySmall!.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
