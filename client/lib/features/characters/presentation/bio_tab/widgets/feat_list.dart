import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/core/widgets/description_text.dart';
import 'package:dnd5e_dm_tools/core/widgets/item_list.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeatsList extends StatefulWidget {
  final Map<String, dynamic> character;
  final String slug;

  const FeatsList({
    super.key,
    required this.character,
    required this.slug,
  });

  @override
  FeatsListState createState() => FeatsListState();
}

class FeatsListState extends State<FeatsList> {
  String selectedFilter = 'Character';
  String selectedFeat = 'none';
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final characterFeats =
        Map<String, Map>.from(widget.character['feats'] ?? {});
    final offline = context.read<SettingsCubit>().state.offlineMode;
    final race = context.read<RulesCubit>().getRace(widget.character['race']);
    final classs =
        context.read<RulesCubit>().getClass(widget.character['class']);

    void onItemsChanged(Map<String, dynamic> newFeats) {
      widget.character['feats'] = newFeats;
      context.read<CharacterBloc>().add(
            CharacterUpdate(
              character: widget.character,
              slug: widget.slug,
              persistData: true,
              offline: offline,
            ),
          );
    }

    void onAddItem() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final feats = context.read<RulesCubit>().getAllFeats();
          final racialFeats = getRacialFeatures(race?['traits'] ?? '');
          var classFeats = <String, dynamic>{};
          classFeats.addAll(getClassFeatures(classs?['desc'] ?? ''));

          final archetype = widget.character['subclass'];
          if (archetype != null) {
            final archetypeClass = classs?['archetypes']
                .firstWhere((arch) => arch['slug'] == archetype);
            final archetypeDesc = archetypeClass['desc'];
            classFeats.addAll(getArchetypeFeatures(archetypeDesc));
          }

          final uniqueClassFeats = <String, dynamic>{...classFeats};

          return StatefulBuilder(
            builder: (context, setState) {
              void updateTextFields(String title, String desc) {
                titleController.text = title;
                descriptionController.text = desc;
              }

              List<DropdownMenuItem<String>> getDropdownItems(
                  Map<String, dynamic> feats) {
                final bool isString = feats.values.first is String;
                return [
                  const DropdownMenuItem(
                    value: 'none',
                    child: Text('None'),
                  ),
                  ...feats.entries.map((entry) => DropdownMenuItem(
                        value: entry.key,
                        child: isString
                            ? Text(entry.key,
                                style: Theme.of(context).textTheme.bodySmall)
                            : entry.value['name'] != null
                                ? Text(entry.value['name'],
                                    style:
                                        Theme.of(context).textTheme.bodySmall)
                                : Text(entry.key,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                      )),
                ];
              }

              return AlertDialog(
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
                            onSelected: (bool selected) {
                              setState(() {
                                selectedFilter = 'Character';
                              });
                            },
                          ),
                          ChoiceChip(
                            label: Text(
                              'Racial',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            selected: selectedFilter == 'Racial',
                            onSelected: (bool selected) {
                              setState(() {
                                selectedFilter = 'Racial';
                              });
                            },
                          ),
                          ChoiceChip(
                            label: Text(
                              'Class',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            selected: selectedFilter == 'Class',
                            onSelected: (bool selected) {
                              setState(() {
                                selectedFilter = 'Class';
                              });
                            },
                          ),
                        ],
                      ),
                      Visibility(
                        visible: selectedFilter == 'Racial',
                        child: DropdownButtonFormField<String>(
                          items: getDropdownItems(racialFeats),
                          onChanged: (value) {
                            setState(() {
                              if (value != 'none') {
                                final title = value!;
                                final desc = racialFeats[value];
                                updateTextFields(title, desc);
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
                          items: getDropdownItems(uniqueClassFeats),
                          onChanged: (value) {
                            setState(() {
                              if (value != 'none') {
                                final title = value!;
                                final desc =
                                    uniqueClassFeats[value]['description'];
                                updateTextFields(title, desc);
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
                          items: getDropdownItems(feats),
                          onChanged: (value) {
                            setState(() {
                              if (value != 'none') {
                                final title = feats[value]['name'];
                                final desc = feats[value]['desc'];
                                updateTextFields(title, desc);
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
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        controller: descriptionController,
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
                      final newFeat = {
                        'name': titleController.text,
                        'desc': descriptionController.text
                      };
                      characterFeats[titleController.text] = newFeat;
                      onItemsChanged(characterFeats);
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.add),
                  ),
                ],
              );
            },
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
            content: DescriptionText(
                inputText: feat.value['desc'],
                baseStyle: Theme.of(context).textTheme.bodySmall!),
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
      items: characterFeats,
      onItemsChanged: onItemsChanged,
      onAddItem: onAddItem,
      tableName: 'Feats',
      displayKey: 'name',
      onSelectItem: onFeatSelected,
      emptyMessage: 'None',
    );
  }
}
