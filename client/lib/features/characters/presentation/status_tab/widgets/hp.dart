import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';

class Hitpoints extends StatefulWidget {
  final Map<String, dynamic> character;
  final String slug;

  const Hitpoints({
    super.key,
    required this.character,
    required this.slug,
  });

  @override
  State<Hitpoints> createState() => HitpointsState();
}

class HitpointsState extends State<Hitpoints> {
  late int currentHp;
  late int maxHp;
  late int tempHp;
  Timer? _timer;
  Timer? _debounceTimer;
  bool tempHpMode = false;

  @override
  void initState() {
    super.initState();
    maxHp = widget.character['hp_max'] ?? 0;
    currentHp = widget.character['hp_curr'] ?? maxHp;
    tempHp = widget.character['hp_temp'] ?? 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _startTimer(int delta, bool offline) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _updateHp(delta, offline);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _debouncePersistCharacter();
  }

  void _debouncePersistCharacter() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 5), () {
      _persistCharacter();
    });
  }

  void _persistCharacter() {
    widget.character['hp_max'] = maxHp;
    widget.character['hp_curr'] = currentHp;
    widget.character['hp_temp'] = tempHp;
    context.read<CharacterBloc>().add(CharacterUpdate(
          character: widget.character,
          slug: widget.slug,
          persistData: true,
          offline: context.read<SettingsCubit>().state.offlineMode,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final editMode = Provider.of<SettingsCubit>(context).state.isEditMode;
    final offline = context.read<SettingsCubit>().state.offlineMode;

    return GestureDetector(
      onTap: editMode ? () => _editHpModal(context) : null,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
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
                  Text('Hit Points',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(width: 8),
                  const Icon(Icons.favorite_outline),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onLongPress: () => _startTimer(-1, offline),
                    onLongPressEnd: (details) => _stopTimer(),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: IconButton(
                          onPressed: () => _updateHp(-1, offline),
                          iconSize: 32,
                          icon: const Icon(Icons.remove_circle_outline)),
                    ),
                  ),
                  GestureDetector(
                    onDoubleTap: () => _showAdjustHpModal(context),
                    child: Text('$currentHp'.padLeft(2, '0'),
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  color: currentHp <= maxHp / 3
                                      ? Colors.redAccent
                                      : currentHp <= maxHp / 2
                                          ? Colors.orange
                                          : currentHp <= maxHp / 1.5
                                              ? Colors.orangeAccent
                                              : Colors.green,
                                )),
                  ),
                  GestureDetector(
                    onLongPress: () => _startTimer(1, offline),
                    onLongPressEnd: (details) => _stopTimer(),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: IconButton(
                          iconSize: 32,
                          onPressed: () => _updateHp(1, offline),
                          icon: const Icon(Icons.add_circle_outline)),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
                width: 45,
                child: Divider(thickness: 2),
              ),
              Text('$maxHp', style: Theme.of(context).textTheme.displaySmall),
              if (tempHp > 0)
                Text('+$tempHp',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.blue)),
              if (currentHp < 1) _buildDeathSave(),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdjustHpModal(BuildContext context) {
    TextEditingController numberController = TextEditingController();
    bool increaseHp = false;
    FocusNode focusNode = FocusNode();

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
                            numberController, increaseHp, focusNode, context);
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

  void _submitChange(TextEditingController numberController, bool increaseHp,
      FocusNode focusNode, BuildContext context) {
    int changeValue = int.tryParse(numberController.text) ?? 0;
    if (!increaseHp) {
      changeValue = -changeValue;
    }
    final offline = context.read<SettingsCubit>().state.offlineMode;
    _updateHp(changeValue, offline);
    focusNode.dispose();
    Navigator.of(context).pop();
  }

  Widget _buildDeathSave() {
    final character = widget.character;
    final deathSave = character['death_save'] ?? [0, 0, 0, 0, 0, 0];

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
                      value: deathSave[i] == 1,
                      onChanged: (value) {
                        setState(() {
                          deathSave[i] = value! ? 1 : 0;
                          character['death_save'] = deathSave;
                          context.read<CharacterBloc>().add(CharacterUpdate(
                                character: character,
                                slug: widget.slug,
                                persistData: false,
                                offline: context
                                    .read<SettingsCubit>()
                                    .state
                                    .offlineMode,
                              ));
                        });
                      }),
              ],
            ),
            Text('Fails', style: Theme.of(context).textTheme.labelSmall),
            Row(
              children: [
                for (int i = 3; i < 6; i++)
                  Checkbox(
                      value: deathSave[i] == 1,
                      onChanged: (value) {
                        setState(() {
                          deathSave[i] = value! ? 1 : 0;
                          character['death_save'] = deathSave;
                          context.read<CharacterBloc>().add(CharacterUpdate(
                                character: character,
                                slug: widget.slug,
                                persistData: false,
                                offline: context
                                    .read<SettingsCubit>()
                                    .state
                                    .offlineMode,
                              ));
                        });
                      }),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _editHpModal(BuildContext context) {
    final TextEditingController maxHpController =
        TextEditingController(text: maxHp.toString());
    final TextEditingController currentHpController =
        TextEditingController(text: currentHp.toString());
    final TextEditingController tempHpController =
        TextEditingController(text: tempHp.toString());

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
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: false, decimal: false),
                  onChanged: (value) {
                    maxHp = int.tryParse(value) ?? maxHp;
                  },
                ),
                TextField(
                  controller: currentHpController,
                  decoration:
                      const InputDecoration(labelText: 'Current Hitpoints'),
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: false, decimal: false),
                  onChanged: (value) {
                    currentHp = int.tryParse(value) ?? currentHp;
                  },
                ),
                TextField(
                  controller: tempHpController,
                  decoration:
                      const InputDecoration(labelText: 'Temporary Hitpoints'),
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: false, decimal: false),
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
                  _persistCharacter();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateHp(int delta, bool offline) {
    if (delta == 0) return;
    setState(() {
      if (delta > 0) {
        if (tempHpMode) {
          tempHp += delta;
        } else {
          int potentialHp = currentHp + delta;
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
      if (offline) {
        _persistCharacter();
      } else {
        _debouncePersistCharacter();
      }
    });
  }
}
