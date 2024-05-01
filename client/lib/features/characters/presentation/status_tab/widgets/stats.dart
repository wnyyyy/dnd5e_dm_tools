import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

class StatsView extends StatelessWidget {
  final Map<String, dynamic> character;
  final VoidCallback? onSave;

  StatsView({
    Key? key,
    required this.character,
    this.onSave,
  }) : super(key: key);

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
          title: Text('Edit Stats'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: acController,
                decoration: InputDecoration(
                  labelText: 'Armor Class',
                ),
                keyboardType: TextInputType.numberWithOptions(
                    signed: false, decimal: false),
              ),
              TextField(
                controller: initiativeController,
                decoration: InputDecoration(
                  labelText: 'Initiative',
                ),
                keyboardType: TextInputType.numberWithOptions(
                    signed: true, decimal: false),
              ),
              TextField(
                controller: speedController,
                decoration: InputDecoration(
                  labelText: 'Speed',
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
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Icon(Icons.check),
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
    return GestureDetector(
      onTap: () => editStats(context),
      child: Card(
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              buildStat(context, 'Armor Class', Icons.shield_outlined, ac),
              Divider(),
              buildStat(
                  context, 'Initiative', RpgAwesome.lightning_bolt, initiative,
                  showSign: true),
              Divider(),
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
