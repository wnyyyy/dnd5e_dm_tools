import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HitDice extends StatefulWidget {
  const HitDice({
    super.key,
    required this.character,
    required this.classs,
    required this.slug,
  });

  final Map<String, dynamic> character;
  final Map<String, dynamic> classs;
  final String slug;

  @override
  State<HitDice> createState() => _HitDiceState();
}

class _HitDiceState extends State<HitDice> {
  @override
  Widget build(BuildContext context) {
    final editMode = Provider.of<SettingsCubit>(context).state.isEditMode;
    final character = widget.character;
    final maxHd = character['hd_max'] ?? character['level'] ?? 1;
    final currentHd = character['hd_curr'] ?? maxHd;
    final hd = widget.classs['hit_dice'] ?? '1d8';

    void editHd(String attributeName) {
      final TextEditingController maxHpController = TextEditingController(
          text: widget.character['hd_max']?.toString() ?? '0');
      final TextEditingController currentHpController = TextEditingController(
          text:
              widget.character['hd_curr']?.toString() ?? maxHpController.text);

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
                      decoration: const InputDecoration(
                        labelText: 'Max Hitdice',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: false, decimal: false),
                    ),
                    TextField(
                      controller: currentHpController,
                      decoration: const InputDecoration(
                        labelText: 'Current Hitdice',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: false, decimal: false),
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
                      widget.character['hd_max'] =
                          int.tryParse(maxHpController.text) ?? 0;
                      widget.character['hd_curr'] =
                          int.tryParse(currentHpController.text) ??
                              int.tryParse(maxHpController.text) ??
                              0;
                      context.read<CharacterBloc>().add(CharacterUpdate(
                          character: widget.character, slug: widget.slug));

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

    void changeHitPoints(int change) {
      int currentHP = character['hd_curr'];

      if (change < 0) {
        currentHP = (currentHP + change < 0) ? 0 : currentHP + change;
      } else {
        currentHP = (currentHP + change > maxHd) ? maxHd : currentHP + change;
      }

      currentHP =
          (currentHP > character['hd_max']) ? character['hd_max'] : currentHP;
      currentHP = (currentHP < 0) ? 0 : currentHP;

      character['hd_curr'] = currentHP;
      context.read<CharacterBloc>().add(CharacterUpdate(
            character: character,
            slug: widget.slug,
            persistData: true,
          ));
    }

    return GestureDetector(
      onTap: editMode ? () => editHd('Hit Dice') : null,
      child: Card.filled(
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('Hit Dice  ($hd)',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => setState(() {
                            changeHitPoints(-1);
                          }),
                        ),
                        Text('$currentHd',
                            style: Theme.of(context).textTheme.displaySmall!),
                        GestureDetector(
                          child: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => setState(() {
                              changeHitPoints(1);
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 40,
                      child: Divider(
                        height: 5,
                        thickness: 2,
                      ),
                    ),
                    Row(
                      children: [
                        Text('$maxHd',
                            style: Theme.of(context).textTheme.displaySmall),
                      ],
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

  Widget buildDeathSave() {
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
