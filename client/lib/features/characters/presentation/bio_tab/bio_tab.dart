import 'package:dnd5e_dm_tools/core/data/repositories/feats_repository.dart';
import 'package:dnd5e_dm_tools/core/widgets/feat_description.dart';
import 'package:dnd5e_dm_tools/core/widgets/item_list.dart';
import 'package:dnd5e_dm_tools/core/widgets/trait_description.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BioTab extends StatelessWidget {
  final Map<String, dynamic> character;
  final Map<String, dynamic> race;
  final Map<String, dynamic> classs;
  final String name;

  const BioTab({
    super.key,
    required this.character,
    required this.name,
    required this.race,
    required this.classs,
  });

  @override
  Widget build(BuildContext context) {
    var feats = Map.castFrom(character['feats']).cast<String, Map>();
    return SingleChildScrollView(
      child: Flex(
        direction: Axis.vertical,
        children: [
          _buildCharImage(name, context),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 32),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.all(64.0),
            child: _buildFeatsList(feats, context),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatsList(
    Map<String, Map>? feats,
    BuildContext context,
  ) {
    if (feats == null) {
      feats = {};
    }

    void _onItemsChanged(Map<String, dynamic> newFeats) {
      character['feats'] = newFeats;
      context.read<CharacterBloc>().add(
            UpdateCharacter(
              character: character,
              name: name,
              classs: classs,
              race: race,
            ),
          );
    }

    void _onAddItem() async {
      final FeatRepository featRepository = context.read<FeatRepository>();
      Map<String, dynamic> availableFeats = await featRepository.getAll();
      if (availableFeats.isEmpty) {
        return;
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          var selectedFeat = availableFeats.entries.first;
          return AlertDialog(
            title: Text('Select a Feat'),
            content: DropdownButtonFormField<String>(
              value: selectedFeat.key,
              items: availableFeats.entries
                  .map((entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value['name']),
                      ))
                  .toList(),
              onChanged: (value) {
                selectedFeat = availableFeats.entries
                    .firstWhere((entry) => entry.key == value);
              },
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Icon(Icons.close),
              ),
              TextButton(
                onPressed: () {
                  if (selectedFeat.key.isNotEmpty) {
                    character['feats'][selectedFeat.key] = selectedFeat.value;
                    _onItemsChanged(character['feats']);
                    Navigator.of(context).pop();
                  }
                },
                child: Icon(Icons.add),
              ),
            ],
          );
        },
      );
    }

    return ItemList(
      items: feats,
      onItemsChanged: _onItemsChanged,
      onAddItem: _onAddItem,
      tableName: 'Feats',
      displayKey: 'name',
    );
  }

  void _showFeatDetails(BuildContext context, Map<String, dynamic> feat) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(feat['name']),
          content: FeatDescription(
            inputText: feat['desc'],
            effectsDesc: feat['effects_desc'],
          ),
          actions: [
            TextButton(
              child: const Icon(Icons.delete),
              onPressed: () {
                character['feats'].remove(feat);
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

  Widget _buildCharImage(String name, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).colorScheme.outline, width: 3),
              ),
              child: Image.asset(
                'assets/char/${name.trim().replaceAll(' ', '_')}.png',
                fit: BoxFit.cover,
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    textAlign: TextAlign.center,
                    name[0].toUpperCase() + name.substring(1).toLowerCase(),
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          fontFamily: GoogleFonts.patuaOne().fontFamily,
                        ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showEditLevel(context),
                    child: Text(
                      'Level ${character['level']}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _showRaceModal(context, race),
                    child: Text(
                      '${race['name']}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${classs['name']}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            )
          ],
        )
      ],
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

  void _showRaceModal(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(data['name']),
          content: TraitDescription(
            inputText: data['traits'],
          ),
        );
      },
    );
  }
}
