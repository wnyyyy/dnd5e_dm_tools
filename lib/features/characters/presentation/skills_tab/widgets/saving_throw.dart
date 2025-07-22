import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SavingThrow extends StatelessWidget {
  const SavingThrow({
    super.key,
    required this.attributePrefix,
    required this.attributeValue,
    this.proficiency,
    required this.color,
    this.onTap,
    this.onLongPress,
  });
  final String attributePrefix;
  final int attributeValue;
  final int? proficiency;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final value = proficiency != null
        ? getModifier(attributeValue) + proficiency!
        : getModifier(attributeValue);
    final valueStr = value >= 0 ? '+$value' : value.toString();
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            Text(
              attributePrefix,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontFamily: GoogleFonts.sourceCodePro().fontFamily,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    valueStr,
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      fontFamily: GoogleFonts.majorMonoDisplay().fontFamily,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                if (proficiency != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.star_outline, color: color, size: 24),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
