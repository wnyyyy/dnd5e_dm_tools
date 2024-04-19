import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ScreenDivider extends StatelessWidget {
  final Function() onUpper;
  final Function() onLower;
  final Function() onMiddle;
  final bool upperHidden;
  final bool lowerHidden;

  const ScreenDivider({
    super.key,
    required this.onUpper,
    required this.onLower,
    required this.onMiddle,
    this.upperHidden = false,
    this.lowerHidden = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceVariant;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: color,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(color: color),
            child: const SizedBox(
              width: double.infinity,
            ),
          ),
          if (!lowerHidden)
            Positioned(
              left: screenWidth * 1 / 3 - 24,
              child: IconButton(
                iconSize: 24,
                icon: const Icon(Icons.expand_more),
                onPressed: onLower,
              ),
            ),
          IconButton(
            iconSize: 24,
            icon: const Icon(
              Icons.horizontal_rule,
            ),
            onPressed: onMiddle,
          ),
          if (!upperHidden)
            Positioned(
              left: screenWidth * 2 / 3 - 24,
              child: IconButton(
                iconSize: 24,
                icon: const Icon(Icons.expand_less),
                onPressed: onUpper,
              ),
            ),
        ],
      ),
    );
  }
}
