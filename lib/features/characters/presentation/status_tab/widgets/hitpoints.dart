import 'dart:async';
import 'dart:math';

import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:flutter/material.dart';

class Hitpoints extends StatefulWidget {
  const Hitpoints({
    super.key,
    required this.character,
    required this.onCharacterUpdated,
  });
  final Character character;
  final ValueChanged<Character> onCharacterUpdated;

  @override
  State<Hitpoints> createState() => HitpointsState();
}

class HitpointsState extends State<Hitpoints> {
  late int currentHp;
  late int maxHp;
  late int tempHp;
  late int prevHp;
  Timer? _timer;
  bool tempHpMode = false;

  @override
  void initState() {
    super.initState();
    maxHp = widget.character.stats.hpMax;
    currentHp = widget.character.stats.hpCurr;
    tempHp = widget.character.stats.hpTemp;
    prevHp = currentHp;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int delta) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _updateHp(delta);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onLongPress: () => setState(() {
                    tempHpMode = !tempHpMode;
                  }),
                  child: Icon(
                    color: tempHpMode ? Colors.blue : null,
                    Icons.favorite_outline,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Hit Points',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onLongPress: () => setState(() {
                    tempHpMode = !tempHpMode;
                  }),
                  child: Icon(
                    color: tempHpMode ? Colors.blue : null,
                    Icons.favorite_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onLongPress: () => _startTimer(-1),
                  onLongPressEnd: (details) => _stopTimer(),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: IconButton(
                      onPressed: () => _updateHp(-1),
                      iconSize: 32,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                  ),
                ),
                GestureDetector(
                  onDoubleTap: () => _showAdjustHpModal(context),
                  child: Text(
                    '$currentHp'.padLeft(2, '0'),
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      color: currentHp <= maxHp / 3
                          ? Colors.redAccent
                          : currentHp <= maxHp / 2
                          ? Colors.orange
                          : currentHp <= maxHp / 1.5
                          ? Colors.orangeAccent
                          : Colors.green,
                    ),
                  ),
                ),
                GestureDetector(
                  onLongPress: () => _startTimer(1),
                  onLongPressEnd: (details) => _stopTimer(),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: IconButton(
                      iconSize: 32,
                      onPressed: () => _updateHp(1),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12, width: 45, child: Divider(thickness: 2)),
            GestureDetector(
              onLongPress: () => _editHpModal(context),
              child: Text(
                '$maxHp',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            if (tempHp > 0)
              Text(
                '+$tempHp',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(color: Colors.blue),
              ),
            if (currentHp < 1) _buildDeathSave(),
          ],
        ),
      ),
    );
  }

  void _showAdjustHpModal(BuildContext context) {
    final TextEditingController numberController = TextEditingController();
    bool increaseHp = false;
    final FocusNode focusNode = FocusNode();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adjust Hit Points'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Flex(
                direction: Axis.horizontal,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ChoiceChip.elevated(
                          showCheckmark: false,
                          selectedColor: Colors.green,
                          label: const Icon(Icons.add),
                          selected: increaseHp,
                          onSelected: (bool selected) {
                            setState(() {
                              increaseHp = true;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        ChoiceChip.elevated(
                          showCheckmark: false,
                          selectedColor: Colors.red,
                          label: const Icon(Icons.remove),
                          selected: !increaseHp,
                          onSelected: (bool selected) {
                            setState(() {
                              increaseHp = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      style: Theme.of(context).textTheme.headlineLarge,
                      autofocus: true,
                      focusNode: focusNode,
                      controller: numberController,
                      keyboardType: TextInputType.number,
                      onSubmitted: (String value) {
                        _submitChange(
                          numberController,
                          increaseHp,
                          focusNode,
                          context,
                        );
                      },
                      decoration: const InputDecoration(
                        hintText: '',
                        labelText: 'Amount',
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Icon(Icons.close),
              onPressed: () {
                focusNode.dispose();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Icon(Icons.done),
              onPressed: () {
                _submitChange(numberController, increaseHp, focusNode, context);
              },
            ),
          ],
        );
      },
    );
  }

  void _submitChange(
    TextEditingController numberController,
    bool increaseHp,
    FocusNode focusNode,
    BuildContext context,
  ) {
    int changeValue = int.tryParse(numberController.text) ?? 0;
    if (!increaseHp) {
      changeValue = -changeValue;
    }
    _updateHp(changeValue);
    focusNode.dispose();
    Navigator.of(context).pop();
  }

  Widget _buildDeathSave() {
    final character = widget.character;
    final deathSave = widget.character.stats.deathSave;

    return Column(
      children: [
        const SizedBox(height: 8),
        Text('Death saves', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Successes', style: Theme.of(context).textTheme.labelSmall),
            Row(
              children: [
                for (int i = 0; i < 3; i++)
                  Checkbox(
                    value: i < deathSave.successes,
                    onChanged: (value) {
                      setState(() {
                        final newDeathSave = deathSave.copyWith(
                          successes: value! ? i + 1 : i,
                        );
                        widget.onCharacterUpdated(
                          character.copyWith(
                            stats: character.stats.copyWith(
                              deathSave: newDeathSave,
                            ),
                          ),
                        );
                      });
                    },
                  ),
              ],
            ),
            Text('Fails', style: Theme.of(context).textTheme.labelSmall),
            Row(
              children: [
                for (int i = 0; i < 3; i++)
                  Checkbox(
                    value: i < deathSave.fails,
                    onChanged: (value) {
                      setState(() {
                        final newDeathSave = deathSave.copyWith(
                          fails: value! ? i + 1 : i,
                        );
                        widget.onCharacterUpdated(
                          character.copyWith(
                            stats: character.stats.copyWith(
                              deathSave: newDeathSave,
                            ),
                          ),
                        );
                      });
                    },
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _editHpModal(BuildContext context) {
    final TextEditingController maxHpController = TextEditingController(
      text: maxHp.toString(),
    );
    final TextEditingController currentHpController = TextEditingController(
      text: currentHp.toString(),
    );
    final TextEditingController tempHpController = TextEditingController(
      text: tempHp.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Hit Points'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: maxHpController,
                  decoration: const InputDecoration(labelText: 'Max Hitpoints'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    maxHp = int.tryParse(value) ?? maxHp;
                  },
                ),
                TextField(
                  controller: currentHpController,
                  decoration: const InputDecoration(
                    labelText: 'Current Hitpoints',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    currentHp = int.tryParse(value) ?? currentHp;
                  },
                ),
                TextField(
                  controller: tempHpController,
                  decoration: const InputDecoration(
                    labelText: 'Temporary Hitpoints',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    tempHp = int.tryParse(value) ?? tempHp;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Icon(Icons.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Icon(Icons.check),
              onPressed: () {
                setState(() {
                  maxHp = int.tryParse(maxHpController.text) ?? maxHp;
                  currentHp =
                      int.tryParse(currentHpController.text) ?? currentHp;
                  tempHp = int.tryParse(tempHpController.text) ?? tempHp;
                  widget.onCharacterUpdated(
                    widget.character.copyWith(
                      stats: widget.character.stats.copyWith(
                        hpMax: maxHp,
                        hpCurr: currentHp,
                        hpTemp: tempHp,
                      ),
                    ),
                  );
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateHp(int delta) {
    if (delta == 0) return;
    setState(() {
      final int prevHp = currentHp;
      if (delta > 0) {
        if (tempHpMode) {
          tempHp += delta;
        } else {
          final int potentialHp = currentHp + delta;
          currentHp = min(potentialHp, maxHp);
        }
      } else if (delta < 0) {
        int remainingDamage = -delta;
        if (tempHp > 0) {
          if (tempHp >= remainingDamage) {
            tempHp -= remainingDamage;
            remainingDamage = 0;
          } else {
            remainingDamage -= tempHp;
            tempHp = 0;
          }
        }
        if (remainingDamage > 0) {
          currentHp = max(0, currentHp - remainingDamage);
        }
      }
      if (prevHp == 0 && currentHp > 0) {
        final character = widget.character;
        final resetDeathSave = character.stats.deathSave.copyWith(
          successes: 0,
          fails: 0,
        );
        widget.onCharacterUpdated(
          character.copyWith(
            stats: character.stats.copyWith(
              deathSave: resetDeathSave,
              hpCurr: currentHp,
            ),
          ),
        );
      } else {
        widget.onCharacterUpdated(
          widget.character.copyWith(
            stats: widget.character.stats.copyWith(
              hpCurr: currentHp,
              hpTemp: tempHp,
            ),
          ),
        );
      }
    });
  }
}
