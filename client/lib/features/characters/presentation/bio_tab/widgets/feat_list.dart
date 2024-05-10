import 'package:dnd5e_dm_tools/core/widgets/feat_description.dart';
import 'package:dnd5e_dm_tools/core/widgets/item_list.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeatsList extends StatelessWidget {
  final Map<String, dynamic> character;
  final String slug;

  const FeatsList({
    super.key,
    required this.character,
    required this.slug,
  });

  @override
  Widget build(BuildContext context) {
    final characterFeats = Map<String, Map>.from(character['feats'] ?? {});
    final offline = context.read<SettingsCubit>().state.offlineMode;

    void onItemsChanged(Map<String, dynamic> newFeats) {
      character['feats'] = newFeats;
      context.read<CharacterBloc>().add(
            CharacterUpdate(
              character: character,
              slug: slug,
              persistData: true,
              offline: offline,
            ),
          );
    }

    void onAddItem(Map<String, dynamic> feats) {
      if (feats.isEmpty) {
        return;
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          var selectedFeat = feats.entries.first;
          return AlertDialog(
            title: const Text('Select a Feat'),
            content: DropdownButtonFormField<String>(
              value: selectedFeat.key,
              items: feats.entries
                  .map((entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value['name']),
                      ))
                  .toList(),
              onChanged: (value) {
                selectedFeat =
                    feats.entries.firstWhere((entry) => entry.key == value);
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
                    characterFeats[selectedFeat.key] = selectedFeat.value;
                    onItemsChanged(characterFeats);
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
      items: characterFeats,
      onItemsChanged: onItemsChanged,
      onAddItem: () async {
        final feats = context.read<RulesCubit>().getAllFeats();
        onAddItem(feats);
      },
      tableName: 'Feats',
      displayKey: 'name',
      onSelectItem: onFeatSelected,
      emptyMessage: 'None',
    );
  }
}
