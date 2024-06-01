import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttributeCard extends StatelessWidget {

  const AttributeCard({
    super.key,
    required this.attributeName,
    required this.attributeValue,
    required this.color,
    this.onTap,
    this.onLongPress,
  });
  final String attributeName;
  final int attributeValue;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final mod = getModifier(attributeValue) >= 0
        ? '+${getModifier(attributeValue)}'
        : getModifier(attributeValue).toString();
    const minWidth = 120.0;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: minWidth,
          maxWidth: minWidth,
        ),
        child: Card(
          elevation: 3,
          surfaceTintColor: color,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(attributeName,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: color,
                        ),),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    SizedBox(
                      width: minWidth - 60,
                      child: Text(
                        mod.padLeft(2),
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontFamily:
                                      GoogleFonts.majorMonoDisplay().fontFamily,
                                ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    SizedBox(
                      height: 16,
                      child: VerticalDivider(
                        color: color,
                        thickness: 1,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        textAlign: TextAlign.left,
                        attributeValue.toString().padLeft(2),
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: color,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
