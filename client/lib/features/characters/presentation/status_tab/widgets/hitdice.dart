import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HitDice extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final editMode = Provider.of<SettingsCubit>(context).state.isEditMode;
    final maxHd = character['hd_max'] ?? character['level'] ?? 1;
    final currentHd = character['hd_curr'] ?? maxHd;
    final hd = classs['hit_dice'] ?? '1d8';

    void editHd(String attributeName) {
      final TextEditingController maxHpController =
          TextEditingController(text: character['hd_max']?.toString() ?? '0');
      final TextEditingController currentHpController = TextEditingController(
          text: character['hd_curr']?.toString() ?? maxHpController.text);

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
                      character['hd_max'] =
                          int.tryParse(maxHpController.text) ?? 0;
                      character['hd_curr'] =
                          int.tryParse(currentHpController.text) ??
                              int.tryParse(maxHpController.text) ??
                              0;
                      context.read<CharacterBloc>().add(
                          CharacterUpdate(character: character, slug: slug));

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
                        Text('$currentHd',
                            style: Theme.of(context).textTheme.displaySmall!),
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
}
