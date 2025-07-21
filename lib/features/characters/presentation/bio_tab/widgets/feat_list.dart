import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
import 'package:dnd5e_dm_tools/core/data/models/race.dart';
import 'package:dnd5e_dm_tools/core/widgets/description_text.dart';
import 'package:dnd5e_dm_tools/core/widgets/generic_list.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_event.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_state.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeatList extends StatelessWidget {
  const FeatList({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final characterState = context.watch<CharacterBloc>().state;
    final rulesState = context.watch<RulesCubit>().state;
    if (characterState is! CharacterLoaded || rulesState is! RulesStateLoaded) {
      return const SizedBox();
    }
    final race = characterState.race;
    final classs = characterState.classs;
    final character = characterState.character;
    final allFeats = rulesState.feats;
    final charFeats = character.getFeatList(allFeats);

    void onItemsChanged(Map<String, dynamic> newFeats) {
      //character['feats'] = newFeats;
      context.read<CharacterBloc>().add(
        CharacterUpdate(character: character, persistData: true),
      );
    }

    // void onAddItem() {
    //   if (classs == null || race == null) return;
    //   showDialog(
    //     context: context,
    //     builder: (context) => _AddFeatDialog(
    //       character: character,
    //       onAdd: (feat) {
    //         feats[feat['name'] ?? ''] = feat;
    //         onItemsChanged(feats);
    //       },
    //     ),
    //   );
    // }

    void onFeatSelected(Feat feat) {
      showDialog(
        context: context,
        builder: (context) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth > 900
                  ? screenWidth * 0.5
                  : screenWidth > 600
                  ? screenWidth * 0.75
                  : screenWidth * 0.9,
              maxHeight: screenHeight * 0.8,
            ),
            child: AlertDialog(
              title: Text(feat.name),
              content: SingleChildScrollView(
                child: DescriptionText(
                  inputText: feat.descOverride ?? feat.description,
                  baseStyle: Theme.of(context).textTheme.bodyMedium!,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      );
    }

    return GenericList(
      items: charFeats,
      onItemsChanged: (newList) {},
      onAddItem: () {},
      tableName: 'Feats',
      onSelectItem: (feat) => onFeatSelected(feat),
      emptyMessage: 'None',
      displayKeyGetter: (feat) => feat.name,
      descriptionGetter: (feat) => feat.description,
    );
  }
}

class _AddFeatDialog extends StatefulWidget {
  const _AddFeatDialog({
    required this.onAdd,
    required this.character,
    required this.race,
    required this.classs,
  });

  final ValueChanged<Map<String, dynamic>> onAdd;
  final Character character;
  final Race race;
  final Class classs;

  @override
  State<_AddFeatDialog> createState() => _AddFeatDialogState();
}

class _AddFeatDialogState extends State<_AddFeatDialog> {
  String selectedFilter = 'Character';
  String selectedFeat = 'none';
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final racialFeats = widget.race.getRacialFeatures();
    final classFeats = widget.classs.getClassFeatures();
    // final classsTable = parseTable(classs?['table']?.toString() ?? '');
    // classFeats.addAll(
    //   getClassFeatures(
    //     classs?['desc']?.toString() ?? '',
    //     level: widget.character['level'] as int? ?? 1,
    //     table: classsTable,
    //   ),
    // );

    // final archetype = widget.character['subclass'];
    // if (archetype != null) {
    //   final archetypes = getArchetypes(classs ?? {});
    //   final archetypeClass =
    //       archetypes
    //           .where((element) => element['slug'] == archetype)
    //           .firstOrNull ??
    //       {};
    //   final archetypeDesc = archetypeClass['desc']?.toString() ?? '';
    //   classFeats.addAll(getArchetypeFeatures(archetypeDesc));
    // }

    // final uniqueClassFeats = <String, dynamic>{...classFeats};
    final screenWidth = MediaQuery.of(context).size.width;

    void updateTextFields(String title, String desc) {
      titleController.text = title;
      descriptionController.text = desc;
    }

    List<DropdownMenuItem<String>> getDropdownItems(
      Map<String, dynamic> feats,
    ) {
      if (feats.isEmpty) {
        return const [DropdownMenuItem(value: 'none', child: Text('None'))];
      }
      final bool isString = feats.values.first is String;
      return [
        const DropdownMenuItem(value: 'none', child: Text('None')),
        ...feats.entries.map(
          (entry) => DropdownMenuItem(
            value: entry.key,
            child: isString
                ? Text(entry.key, style: Theme.of(context).textTheme.bodySmall)
                : (entry.value as Map)['name'] != null
                ? Text(
                    (entry.value as Map)['name']?.toString() ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : Text(entry.key, style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
      ];
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: screenWidth > 900
            ? screenWidth * 0.5
            : screenWidth > 600
            ? screenWidth * 0.75
            : screenWidth * 0.9,
      ),
      child: AlertDialog(
        title: const Text('Select a Feat'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8.0,
                children: [
                  ChoiceChip(
                    label: Text(
                      'Character',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    selected: selectedFilter == 'Character',
                    onSelected: (selected) {
                      setState(() => selectedFilter = 'Character');
                    },
                  ),
                  ChoiceChip(
                    label: Text(
                      'Racial',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    selected: selectedFilter == 'Racial',
                    onSelected: (selected) {
                      setState(() => selectedFilter = 'Racial');
                    },
                  ),
                  ChoiceChip(
                    label: Text(
                      'Class',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    selected: selectedFilter == 'Class',
                    onSelected: (selected) {
                      setState(() => selectedFilter = 'Class');
                    },
                  ),
                ],
              ),
              Visibility(
                visible: selectedFilter == 'Racial',
                child: DropdownButtonFormField<String>(
                  items: getDropdownItems({}),
                  onChanged: (value) {
                    setState(() {
                      if (value != 'none') {
                        final title = value!;
                        //final desc = racialFeats[value]?.toString() ?? '';
                        updateTextFields(title, 'desc');
                      } else {
                        titleController.clear();
                        descriptionController.clear();
                      }
                    });
                  },
                ),
              ),
              Visibility(
                visible: selectedFilter == 'Class',
                child: DropdownButtonFormField<String>(
                  items: getDropdownItems({}),
                  onChanged: (value) {
                    setState(() {
                      if (value != 'none') {
                        final title = value!;
                        // final desc =
                        //     (uniqueClassFeats[value] as Map?)?['description']
                        //         ?.toString() ??
                        //     '';
                        updateTextFields(title, 'desc');
                      } else {
                        titleController.clear();
                        descriptionController.clear();
                      }
                    });
                  },
                ),
              ),
              Visibility(
                visible: selectedFilter == 'Character',
                child: DropdownButtonFormField<String>(
                  items: getDropdownItems({}),
                  onChanged: (value) {
                    setState(() {
                      if (value != 'none') {
                        // final feat = feats[value] as Map? ?? {};
                        // final title = feat['name']?.toString() ?? '';
                        // final desc = feat['desc']?.toString() ?? '';
                        updateTextFields('title', 'desc');
                      } else {
                        titleController.clear();
                        descriptionController.clear();
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                controller: titleController,
              ),
              TextField(
                minLines: 3,
                maxLines: null,
                decoration: const InputDecoration(labelText: 'Description'),
                controller: descriptionController,
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close),
          ),
          TextButton(
            onPressed: () {
              final newFeat = {
                'name': titleController.text,
                'desc': descriptionController.text,
              };
              widget.onAdd(newFeat);
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
