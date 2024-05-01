import 'package:dnd5e_dm_tools/core/config/app_colors.dart';
import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/skills_tab.dart/widgets/saving_throw.dart';
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

  @override
  Widget build(BuildContext context) {
    final editMode = Provider.of<SettingsCubit>(context).state.isEditMode;
    final character = widget.character;
    final maxHp = character['hp_max'] ?? 0;
    final currentHp = character['hp_curr'] ?? maxHp;
    final tempHp = character['hp_temp'] ?? 0;

    void editSavingThrow(String attributeName) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final attr = attributeName.toLowerCase();
          bool isProficient = char_prof.contains(attr);
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return AlertDialog(
                title: Text('Edit $attributeName Saving Throw'),
                content: CheckboxListTile(
                  title: Text('Proficient'),
                  value: isProficient,
                  onChanged: (bool? value) {
                    if (value != null) {
                      setDialogState(() {
                        if (value) {
                          if (!char_prof.contains(attr)) {
                            char_prof.add(attr);
                          }
                        } else {
                          char_prof.remove(attr);
                        }
                        isProficient = value;
                      });
                    }
                  },
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
                      widget.character['prof_saving_throws'] =
                          char_prof.join(',');
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

    return Card.filled(
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text('Hit Points', style: Theme.of(context).textTheme.titleSmall),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
