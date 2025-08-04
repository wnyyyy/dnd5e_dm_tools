import 'package:dnd5e_dm_tools/core/data/models/action.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/data/models/spellbook.dart';
import 'package:flutter/material.dart' hide Action;

class HitDice extends StatelessWidget {
  const HitDice({
    super.key,
    required this.character,
    required this.classs,
    required this.onCharacterUpdated,
  });

  final Character character;
  final Class classs;

  final ValueChanged<Character> onCharacterUpdated;

  @override
  Widget build(BuildContext context) {
    final maxHd = character.stats.hdMax;
    final currentHd = character.stats.hdCurr;
    final hd = classs.hitDice;

    void editHd(String attributeName) {
      final TextEditingController maxHpController = TextEditingController(
        text: maxHd.toString(),
      );
      final TextEditingController currentHpController = TextEditingController(
        text: currentHd.toString(),
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Edit $attributeName Hitpoints'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: maxHpController,
                  decoration: const InputDecoration(labelText: 'Max Hitdice'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: currentHpController,
                  decoration: const InputDecoration(
                    labelText: 'Current Hitdice',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              TextButton(
                child: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Icon(Icons.check),
                onPressed: () {
                  final int newMaxHd =
                      int.tryParse(maxHpController.text) ?? maxHd;
                  final int newCurrentHd =
                      int.tryParse(currentHpController.text) ?? currentHd;
                  final updatedCharacter = character.copyWith(
                    stats: character.stats.copyWith(
                      hdMax: newMaxHd,
                      hdCurr: newCurrentHd,
                    ),
                  );
                  onCharacterUpdated(updatedCharacter);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void showRestDialog(int currHitDie, int maxHitDie) {
      bool isShort = true;
      int currHitDieInput = currHitDie;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Rest'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        ChoiceChip(
                          label: const Text('Short'),
                          selected: isShort,
                          onSelected: (selected) {
                            if (!isShort) {
                              setState(() {
                                isShort = true;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 24),
                        ChoiceChip(
                          label: const Text('Long'),
                          selected: !isShort,
                          onSelected: (selected) {
                            if (isShort) {
                              setState(() {
                                isShort = false;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    if (isShort)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: IconButton(
                                    onPressed: () {
                                      if (currHitDieInput > 0) {
                                        setState(() {
                                          currHitDieInput--;
                                        });
                                      }
                                    },
                                    iconSize: 32,
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$currHitDieInput',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displaySmall,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 6.0),
                                  child: IconButton(
                                    iconSize: 32,
                                    onPressed: () {
                                      if (currHitDieInput < currHitDie) {
                                        setState(() {
                                          currHitDieInput++;
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions: [
                  TextButton(
                    child: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Icon(Icons.check),
                    onPressed: () {
                      Navigator.of(context).pop();
                      final int newCurrentHd;
                      List<Action> updatedActions = character.actions;
                      Spellbook updatedSpellbook = character.spellbook;
                      if (isShort) {
                        if (currHitDieInput > 0) {
                          newCurrentHd = currentHd - currHitDieInput;
                        } else {
                          newCurrentHd = currentHd;
                        }
                        updatedActions = character.restoreActions(
                          shortRest: true,
                        );
                      } else {
                        newCurrentHd = maxHitDie;
                        updatedActions = character.restoreActions();
                        updatedSpellbook = updatedSpellbook.resetSlots();
                      }
                      final updatedCharacter = character.copyWith(
                        stats: character.stats.copyWith(hdCurr: newCurrentHd),
                        actions: updatedActions,
                        spellbook: updatedSpellbook,
                      );
                      onCharacterUpdated(updatedCharacter);
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return GestureDetector(
      onLongPress: () => editHd('Hit Dice'),
      child: Card(
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 2.0, bottom: 2.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hit Dice',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text('($hd)', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const SizedBox(width: 14.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$currentHd | $maxHd',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => showRestDialog(currentHd, maxHd),
                  child: const Text('Rest'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
