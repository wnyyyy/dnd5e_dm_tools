import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

class StatsWidget extends StatelessWidget {
  const StatsWidget({
    super.key,
    required this.character,
    required this.onCharacterUpdated,
  });
  final Character character;
  final ValueChanged<Character> onCharacterUpdated;

  @override
  Widget build(BuildContext context) {
    final ac = character.stats.ac;
    final initiative = character.stats.initiative;
    final speed = character.stats.speed;

    return GestureDetector(
      onLongPress: () => editStats(context),
      child: Card(
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              buildStat(context, 'Armor Class', Icons.shield_outlined, ac),
              const Divider(),
              buildStat(
                context,
                'Initiative',
                RpgAwesome.lightning_bolt,
                initiative,
                showSign: true,
              ),
              const Divider(),
              buildStat(context, 'Speed', Icons.directions_run, speed),
            ],
          ),
        ),
      ),
    );
  }

  void editStats(BuildContext context) {
    final ac = character.stats.ac;
    final initiative = character.stats.initiative;
    final speed = character.stats.speed;

    final TextEditingController acController = TextEditingController(
      text: ac.toString(),
    );
    final TextEditingController initiativeController = TextEditingController(
      text: initiative.toString(),
    );
    final TextEditingController speedController = TextEditingController(
      text: speed.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Stats'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: acController,
                decoration: const InputDecoration(labelText: 'Armor Class'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: initiativeController,
                decoration: const InputDecoration(labelText: 'Initiative'),
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                ),
              ),
              TextField(
                controller: speedController,
                decoration: const InputDecoration(labelText: 'Speed'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Icon(Icons.check),
              onPressed: () {
                final newAc = int.tryParse(acController.text) ?? ac;
                final newInitiative =
                    int.tryParse(initiativeController.text) ?? initiative;
                final newSpeed = int.tryParse(speedController.text) ?? speed;
                final updatedCharacter = character.copyWith(
                  stats: character.stats.copyWith(
                    ac: newAc,
                    initiative: newInitiative,
                    speed: newSpeed,
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

  Widget buildStat(
    BuildContext context,
    String label,
    IconData icon,
    int value, {
    bool showSign = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(label, style: Theme.of(context).textTheme.titleSmall),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(icon, size: 24),
            ),
            Text(
              showSign
                  ? (value >= 0 ? '+$value' : value.toString())
                  : value.toString(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ],
    );
  }
}
