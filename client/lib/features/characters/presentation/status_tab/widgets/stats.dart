import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

class StatsView extends StatelessWidget {
  final Map<String, dynamic> character;
  final VoidCallback? onSave;

  const StatsView({
    super.key,
    required this.character,
    this.onSave,
  });

  void editStats(BuildContext context) {
    final TextEditingController acController =
        TextEditingController(text: character['ac']?.toString() ?? '0');
    final TextEditingController initiativeController = TextEditingController(
        text: character['initiative']?.toString() ??
            getModifier(character['asi']?['dexterity']).toString());
    final TextEditingController speedController =
        TextEditingController(text: character['speed']?.toString() ?? '30');

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
                decoration: const InputDecoration(
                  labelText: 'Armor Class',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    signed: false, decimal: false),
              ),
              TextField(
                controller: initiativeController,
                decoration: const InputDecoration(
                  labelText: 'Initiative',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    signed: true, decimal: false),
              ),
              TextField(
                controller: speedController,
                decoration: const InputDecoration(
                  labelText: 'Speed',
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
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Icon(Icons.check),
              onPressed: () {
                character['ac'] = int.tryParse(acController.text) ?? 0;
                character['initiative'] =
                    int.tryParse(initiativeController.text) ??
                        getModifier(character['asi']?['dexterity']);
                character['speed'] = int.tryParse(speedController.text) ?? 30;
                onSave?.call();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ac = int.tryParse(character['ac'].toString()) ?? 0;
    final initiative = int.tryParse(character['initiative'].toString()) ??
        getModifier(character['asi']?['dexterity']);
    final speed = int.tryParse(character['speed'].toString()) ?? 30;
    final editMode = context.read<SettingsCubit>().state.isEditMode;
    return GestureDetector(
      onLongPress: () => editStats(context),
      onTap: () => editMode ? editStats(context) : null,
      child: Card(
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              buildStat(context, 'Armor Class', Icons.shield_outlined, ac),
              const Divider(),
              buildStat(
                  context, 'Initiative', RpgAwesome.lightning_bolt, initiative,
                  showSign: true),
              const Divider(),
              buildStat(context, 'Speed', Icons.directions_run, speed),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStat(BuildContext context, String label, IconData icon, int value,
      {bool showSign = false}) {
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
