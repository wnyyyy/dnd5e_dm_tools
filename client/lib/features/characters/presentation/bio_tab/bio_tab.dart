import 'package:dnd5e_dm_tools/core/data/repositories/feat_repository.dart';
import 'package:dnd5e_dm_tools/core/widgets/feat_description.dart';
import 'package:dnd5e_dm_tools/core/widgets/item_list.dart';
import 'package:dnd5e_dm_tools/core/widgets/trait_description.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
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
    var feats = Map.castFrom(character['feats'] ?? {}).cast<String, Map>();
    var proficiencies =
        Map.castFrom(character['proficiencies'] ?? {}).cast<String, Map>();
    final screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Flex(
        direction: Axis.vertical,
        children: [
          _buildCharImage(name, context),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: 4, horizontal: screenWidth * 0.08),
            child: const Divider(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08, vertical: 8),
            child: _buildProficiencyList(proficiencies, context),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08, vertical: 8),
            child: _buildFeatsList(feats, context),
          ),
        ],
      ),
    );
  }

  Widget _buildProficiencyList(
    Map<String, dynamic> proficiencies,
    BuildContext context,
  ) {
    void onItemsChanged(Map<String, dynamic> newProficiencies) {
      character['proficiencies'] = newProficiencies;
      context.read<CharacterBloc>().add(
            CharacterUpdate(
              character: character,
              name: name,
              classs: classs,
              race: race,
              persistData: true,
            ),
          );
    }

    void onAddItem() async {
      final TextEditingController titleController = TextEditingController();
      final TextEditingController descriptionController =
          TextEditingController();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add proficiency'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                    minLines: 3,
                    maxLines: 5,
                  ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.close),
              ),
              TextButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    var slug = titleController.text
                        .toLowerCase()
                        .trim()
                        .replaceAll(' ', '_');
                    var newProf = proficiencies;
                    newProf[slug] = {
                      'title': titleController.text,
                      'description': descriptionController.text,
                    };
                    onItemsChanged(newProf);
                    Navigator.of(context).pop();
                  }
                },
                child: const Icon(Icons.add),
              ),
            ],
          );
        },
      );
    }

    void onProficiencySelected(MapEntry<String, Map> proficiency) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(proficiency.value['title']),
            content: Text(proficiency.value['description']),
            actions: [
              TextButton(
                child: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }

    return ItemList(
      items: proficiencies.cast<String, Map>(),
      onItemsChanged: onItemsChanged,
      onAddItem: onAddItem,
      tableName: 'Proficiencies',
      displayKey: 'title',
      emptyMessage: 'None',
      onSelectItem: onProficiencySelected,
    );
  }

  Widget _buildFeatsList(
    Map<String, Map> feats,
    BuildContext context,
  ) {
    void onItemsChanged(Map<String, dynamic> newFeats) {
      character['feats'] = newFeats;
      context.read<CharacterBloc>().add(
            CharacterUpdate(
              character: character,
              name: name,
              classs: classs,
              race: race,
              persistData: true,
            ),
          );
    }

    void onAddItem() async {
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
            title: const Text('Select a Feat'),
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
                child: const Icon(Icons.close),
              ),
              TextButton(
                onPressed: () {
                  if (selectedFeat.key.isNotEmpty) {
                    character['feats'][selectedFeat.key] = selectedFeat.value;
                    onItemsChanged(character['feats']);
                    Navigator.of(context).pop();
                  }
                },
                child: const Icon(Icons.add),
              ),
            ],
          );
        },
      );
    }

    void onFeatSelected(MapEntry<String, Map> feat) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(feat.value['name']),
            content: FeatDescription(
              inputText: feat.value['desc'],
              effectsDesc: List<String>.from(feat.value['effects_desc'] ?? []),
            ),
            actions: [
              TextButton(
                child: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }

    return ItemList(
      items: feats,
      onItemsChanged: onItemsChanged,
      onAddItem: onAddItem,
      tableName: 'Feats',
      displayKey: 'name',
      onSelectItem: onFeatSelected,
      emptyMessage: 'None',
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
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => context.read<SettingsCubit>().state.isEditMode
                        ? _showEditLevel(context)
                        : null,
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
                  const SizedBox(height: 8),
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
              context.read<CharacterBloc>().add(CharacterUpdate(
                    character: character,
                    name: name,
                    classs: classs,
                    race: race,
                  ));
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
          actions: [
            TextButton(
              child: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
