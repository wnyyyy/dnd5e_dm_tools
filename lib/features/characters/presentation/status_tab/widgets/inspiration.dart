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
    final color = inspiration > 0 ? Colors.green : null;

    void updateInspiration(int newInspiration) {
      final updatedCharacter = character.copyWith(
        stats: character.stats.copyWith(inspiration: newInspiration),
      );
      onCharacterUpdated(updatedCharacter);
    }

    return GestureDetector(
      onTap: () {
        if (inspiration < 5) {
          updateInspiration(inspiration + 1);
        }
      },
      child: Card(
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Inspiration',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Column(
                  children: [
                    if (inspiration > 0)
                      IconButton(
                        iconSize: 32,
                        onPressed: () {
                          if (inspiration > 0) {
                            updateInspiration(inspiration - 1);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                    Text(
                      '$inspiration',
                      style: Theme.of(
                        context,
                      ).textTheme.displaySmall!.copyWith(color: color),
                    ),
                    IconButton(
                      iconSize: 32,
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
        ),
      ),
    );
  }
}
