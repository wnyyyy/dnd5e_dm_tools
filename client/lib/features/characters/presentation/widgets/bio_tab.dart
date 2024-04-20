import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
import 'package:flutter/material.dart';

class BioTab extends StatelessWidget {
  final Character character;

  const BioTab({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
                'assets/char/${character.name.toLowerCase().trim().replaceAll(' ', '_')}.png'),
          ),
          Text('${character.name} - ${character.race}'),
          GestureDetector(
            onTap: () => _showEditLevel(context),
            child: Text('Level: ${character.level}',
                style: const TextStyle(decoration: TextDecoration.underline)),
          ),
          ListTile(
            title: const Text('Feats'),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addFeat(context),
            ),
          ),
          _buildFeatList(context),
        ],
      ),
    );
  }

  void _showEditLevel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: 20,
          itemBuilder: (context, index) => ListTile(
            title: Text('Level ${index + 1}'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  Widget _buildFeatList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: character.feats.length,
      itemBuilder: (context, index) {
        var feat = character.feats[index];
        return ListTile(
          title: Text(feat.name),
          onTap: () => _showFeatDetails(context, feat),
        );
      },
    );
  }

  void _addFeat(BuildContext context) {
    // Add functionality to input and add a new feat to the character
  }

  void _showFeatDetails(BuildContext context, Feat feat) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(feat.name),
          content: Text(feat.description),
          actions: [
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                character.feats.remove(feat);
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
