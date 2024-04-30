import 'package:flutter/material.dart';

class StatusTab extends StatelessWidget {
  final Map<String, dynamic> character;
  final Map<String, dynamic> race;
  final Map<String, dynamic> classs;
  final String name;

  const StatusTab({
    super.key,
    required this.character,
    required this.name,
    required this.race,
    required this.classs,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Flex(
          direction: Axis.horizontal,
          children: [
            _buildHitpoints(context),
            _buildHitDice(),
          ],
        ),
      ),
    );
  }

  Widget _buildHitpoints(BuildContext context) {
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Hit Points', style: Theme.of(context).textTheme.titleSmall),
            SizedBox(height: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('${character['hp_max']}',
                    style: Theme.of(context).textTheme.displaySmall),
                Divider(
                  height: 3,
                  color: Colors.black,
                  thickness: 3,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () => _changeHitPoints(-1),
                    ),
                    Text(
                      '${character['currentHP']} / ${character['maxHP']}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: () => _changeHitPoints(1),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _changeHitPoints(int change) {
    int currentHP = character['currentHP'];
    currentHP += change;
    if (currentHP >= 0 && currentHP <= character['maxHP']) {
      character['currentHP'] = currentHP;
    }
  }

  Widget _buildHitDice() {
    return Container();
  }
}
