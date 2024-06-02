import 'dart:collection';

import 'package:dnd5e_dm_tools/core/widgets/item_list.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProficiencyList extends StatelessWidget {
  const ProficiencyList({
    super.key,
    required this.character,
    required this.slug,
  });
  final Map<String, dynamic> character;
  final String slug;

  @override
  Widget build(BuildContext context) {
    final proficiencies = Map<String, Map>.from(
        character['proficiencies'] as LinkedHashMap? ?? {},);
    final offline = context.read<SettingsCubit>().state.offlineMode;
    void onItemsChanged(Map<String, dynamic> newProficiencies) {
      character['proficiencies'] = newProficiencies;
      context.read<CharacterBloc>().add(
            CharacterUpdate(
              character: character,
              slug: slug,
              persistData: true,
              offline: offline,
            ),
          );
    }

    Future<void> onAddItem() async {
      final TextEditingController titleController = TextEditingController();
      final TextEditingController descriptionController =
          TextEditingController();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final screenWidth = MediaQuery.of(context).size.width;
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth > 900
                  ? screenWidth * 0.5
                  : screenWidth > 600
                      ? screenWidth * 0.75
                      : screenWidth * 0.9,
            ),
            child: AlertDialog(
              title: const Text('Add proficiency'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                  maxHeight: 300,
                ),
                child: SingleChildScrollView(
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
                      final slug = titleController.text
                          .toLowerCase()
                          .trim()
                          .replaceAll(' ', '_');
                      final newProf = proficiencies;
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
            ),
          );
        },
      );
    }

    void onProficiencySelected(MapEntry<String, Map> proficiency) {
      showDialog(
        context: context,
        builder: (context) {
          final screenWidth = MediaQuery.of(context).size.width;
          return AlertDialog(
            title: Text(proficiency.value['title']?.toString() ?? 'Error'),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenWidth > 900
                    ? screenWidth * 0.5
                    : screenWidth > 600
                        ? screenWidth * 0.75
                        : screenWidth * 0.9,
              ),
              child: SingleChildScrollView(
                child: Text(proficiency.value['description']?.toString() ?? ''),
              ),
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
      items: proficiencies.cast<String, Map>(),
      onItemsChanged: onItemsChanged,
      onAddItem: onAddItem,
      tableName: 'Proficiencies',
      displayKey: 'title',
      emptyMessage: 'None',
      onSelectItem: onProficiencySelected,
    );
  }
}
