import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:flutter/material.dart';

class Inspiration extends StatelessWidget {
  const Inspiration({
    super.key,
    required this.character,
    required this.onCharacterUpdated,
  });

  final Character character;
  final ValueChanged<Character> onCharacterUpdated;

  @override
  Widget build(BuildContext context) {
    final int inspiration = character.stats.inspiration;
    final exhaustion = character.stats.exhaustion;
    final color = inspiration > 0 ? Colors.green : null;
    final exhaustionColor = exhaustion > 0 ? Colors.red : null;

    void updateInspiration(int newInspiration) {
      final updatedCharacter = character.copyWith(
        stats: character.stats.copyWith(inspiration: newInspiration),
      );
      onCharacterUpdated(updatedCharacter);
    }

    void updateExhaustion(int newExhaustion) {
      final updatedCharacter = character.copyWith(
        stats: character.stats.copyWith(exhaustion: newExhaustion),
      );
      onCharacterUpdated(updatedCharacter);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Visibility(
                        visible: inspiration > 0,
                        maintainAnimation: true,
                        maintainSize: true,
                        maintainState: true,
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          iconSize: 24,
                          onPressed: () {
                            if (inspiration > 0) {
                              updateInspiration(inspiration - 1);
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                      ),
                      Text(
                        'Inspiration',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        '$inspiration',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge!.copyWith(color: color),
                      ),
                      IconButton(
                        iconSize: 24,
                        visualDensity: VisualDensity.compact,

                        onPressed: () {
                          updateInspiration(inspiration + 1);
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48, child: VerticalDivider()),
            SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Visibility(
                        visible: exhaustion > 0,
                        maintainAnimation: true,
                        maintainSize: true,
                        maintainState: true,
                        child: IconButton(
                          visualDensity: VisualDensity.compact,

                          iconSize: 24,
                          onPressed: () {
                            if (exhaustion > 0) {
                              updateExhaustion(exhaustion - 1);
                            }
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                      ),
                      Text(
                        'Exhaustion',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        '$exhaustion',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: exhaustionColor,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,

                        iconSize: 24,
                        onPressed: () {
                          updateExhaustion(exhaustion + 1);
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
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
