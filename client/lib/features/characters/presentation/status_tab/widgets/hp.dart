import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Hitpoints extends StatefulWidget {
  const Hitpoints({
    super.key,
    required this.character,
    required this.classs,
    required this.race,
    required this.name,
  });

  final Map<String, dynamic> character;
  final Map<String, dynamic> classs;
  final Map<String, dynamic> race;
  final String name;

  @override
  State<Hitpoints> createState() => _HitpointsState();
}

class _HitpointsState extends State<Hitpoints> {
  late List<String> char_prof;
  bool tempHpMode = false;
  bool deathSaveMode = false;

  @override
  Widget build(BuildContext context) {
    final editMode = Provider.of<SettingsCubit>(context).state.isEditMode;
    final character = widget.character;
    final maxHp = character['hp_max'] ?? 0;
    final currentHp = character['hp_curr'] ?? maxHp;
    final tempHp = character['hp_temp'] ?? 0;
    deathSaveMode = currentHp < 1;

    void editHp(String attributeName) {
      final TextEditingController maxHpController = TextEditingController(
          text: widget.character['hp_max']?.toString() ?? '0');
      final TextEditingController currentHpController = TextEditingController(
          text:
              widget.character['hp_curr']?.toString() ?? maxHpController.text);
      final TextEditingController tempHpController = TextEditingController(
          text: widget.character['hp_temp']?.toString() ?? '0');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return AlertDialog(
                title: Text('Edit $attributeName Hitpoints'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: maxHpController,
                      decoration: InputDecoration(
                        labelText: 'Max Hitpoints',
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                          signed: false, decimal: false),
                    ),
                    TextField(
                      controller: currentHpController,
                      decoration: InputDecoration(
                        labelText: 'Current Hitpoints',
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                          signed: false, decimal: false),
                    ),
                    TextField(
                      controller: tempHpController,
                      decoration: InputDecoration(
                        labelText: 'Temporary Hitpoints',
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                          signed: false, decimal: false),
                    ),
                  ],
                ),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actions: <Widget>[
                  TextButton(
                    child: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Icon(Icons.check),
                    onPressed: () {
                      widget.character['hp_max'] =
                          int.tryParse(maxHpController.text) ?? 0;
                      widget.character['hp_curr'] =
                          int.tryParse(currentHpController.text) ??
                              int.tryParse(maxHpController.text) ??
                              0;
                      widget.character['hp_temp'] =
                          int.tryParse(tempHpController.text) ?? 0;

                      context.read<CharacterBloc>().add(CharacterUpdate(
                          character: widget.character,
                          race: widget.race,
                          classs: widget.classs,
                          name: widget.name));

                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    }

    void _changeHitPoints(int change) {
      int currentHP = character['hp_curr'];
      int tempHP = character['hp_temp'] ?? 0;

      if (change < 0) {
        if (tempHP > 0) {
          int remainingDamage = -change;
          if (tempHP >= remainingDamage) {
            character['hp_temp'] -= remainingDamage;
            tempHP -= remainingDamage;
          } else {
            remainingDamage -= tempHP;
            character['hp_temp'] = 0;
            currentHP -= remainingDamage;
          }
        } else {
          currentHP += change;
        }
      } else {
        if (tempHpMode) {
          character['hp_temp'] = tempHP + change;
        } else {
          currentHP += change;
        }
      }

      currentHP =
          (currentHP > character['hp_max']) ? character['hp_max'] : currentHP;
      currentHP = (currentHP < 0) ? 0 : currentHP;

      character['hp_curr'] = currentHP;
      context.read<CharacterBloc>().add(CharacterUpdate(
            character: character,
            race: widget.race,
            classs: widget.classs,
            name: widget.name,
            persistData: false,
          ));
    }

    return GestureDetector(
      onTap: editMode ? () => editHp('Hit Points') : null,
      child: Card.filled(
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('Hit Points',
                    style: Theme.of(context).textTheme.titleSmall),
                SizedBox(height: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline),
                          onPressed: () => setState(() {
                            _changeHitPoints(-1);
                          }),
                        ),
                        Text('${currentHp}'.padLeft(2, '0'),
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(
                                  color: currentHp <= maxHp / 3
                                      ? Colors.redAccent
                                      : currentHp <= maxHp / 2
                                          ? Colors.orange
                                          : currentHp <= maxHp / 1.5
                                              ? Colors.orangeAccent
                                              : Colors.green,
                                )),
                        GestureDetector(
                          onLongPress: () => setState(() {
                            tempHpMode = !tempHpMode;
                          }),
                          child: IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            color: tempHpMode ? Colors.green : null,
                            onPressed: () => setState(() {
                              _changeHitPoints(1);
                            }),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 40,
                      child: Divider(
                        height: 5,
                        thickness: 2,
                      ),
                    ),
                    Row(
                      children: [
                        Text('${maxHp}',
                            style: Theme.of(context).textTheme.displaySmall),
                        if (tempHp > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text('+${tempHp}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      color: Colors.blue,
                                    )),
                          ),
                      ],
                    ),
                    if (deathSaveMode) buildDeathSave(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDeathSave() {
    final character = widget.character;
    final deathSave = character['death_save'] ?? [0, 0, 0, 0, 0, 0];

    return Column(
      children: [
        SizedBox(height: 8),
        Text('Death saves', style: Theme.of(context).textTheme.titleSmall),
        SizedBox(height: 8),
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
                                race: widget.race,
                                classs: widget.classs,
                                name: widget.name,
                                persistData: false,
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
                                race: widget.race,
                                classs: widget.classs,
                                name: widget.name,
                                persistData: false,
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
}
