import 'package:dnd5e_dm_tools/core/widgets/feat_description.dart';
import 'package:dnd5e_dm_tools/core/widgets/item_list.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_states.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_bloc.dart';
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
    return BlocBuilder(builder: (context, state) {
      if (state is CharacterStateLoaded) {
        final character = state.character;
        final characterFeatSlugs = character['feats'];
        final characterFeats = {}.cast<String, Map>();
        characterFeatSlugs.forEach(
          (key, value) async {
            final feat = context.read<RulesCubit>().getFeat(key);
            if (feat != null) {
              characterFeats[key] = feat;
            }
          },
        );

        void onItemsChanged(Map<String, dynamic> newFeats) {
          character['feats'] = newFeats;
          context.read<CharacterBloc>().add(
                CharacterUpdate(
                  character: character,
                  slug: slug,
                  persistData: true,
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
                        character['feats'][selectedFeat.key] =
                            selectedFeat.value;
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
                  effectsDesc:
                      List<String>.from(feat.value['effects_desc'] ?? []),
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
      return Container();
    });
  }
}
